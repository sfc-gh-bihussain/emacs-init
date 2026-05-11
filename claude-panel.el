;;; claude-panel.el --- Active Claude agent panel  -*- lexical-binding: t -*-
;;
;; Shows all active Claude Code instances (live agent-shell buffers + headless
;; processes) with subagent trees, live status, and a transcript preview pane.
;; Relies on my/claude-* helpers defined in init.el.

(require 'tabulated-list)
(require 'map)
(require 'seq)
(require 'json)

;;; Customization ──────────────────────────────────────────────────────────────

(defgroup claude-panel nil
  "Active Claude agent panel."
  :group 'tools)

(defcustom claude-panel-height 12
  "Height of the Claude Panel bottom window in lines."
  :type 'integer
  :group 'claude-panel)

(defcustom claude-panel-preview-width 90
  "Width of the preview side window in columns."
  :type 'integer
  :group 'claude-panel)

(defcustom claude-panel-refresh-interval 5
  "Idle seconds before panel auto-refreshes."
  :type 'number
  :group 'claude-panel)

(defcustom claude-panel-subagent-active-threshold 120
  "Subagent is active if its JSONL was modified within this many seconds."
  :type 'number
  :group 'claude-panel)

;;; State ──────────────────────────────────────────────────────────────────────

(defvar claude-panel--buffer nil)
(defvar claude-panel--preview-buffer nil)
(defvar claude-panel--timer nil)

;;; Subagent discovery ─────────────────────────────────────────────────────────

(defun claude-panel--subagents (session-id project-dir)
  "Return list of subagent plists for SESSION-ID inside PROJECT-DIR.
Each plist: (:agent-id :agent-type :description :mtime :jsonl-file)."
  (let* ((subs-dir (expand-file-name
                    (concat session-id "/subagents")
                    (expand-file-name project-dir "~/.claude/projects/")))
         result)
    (when (file-directory-p subs-dir)
      (dolist (meta-file (directory-files subs-dir t "\\.meta\\.json$" t))
        (condition-case nil
            (let* ((bname     (file-name-nondirectory meta-file))
                   (agent-key (replace-regexp-in-string "\\.meta\\.json$" "" bname))
                   (jsonl     (expand-file-name (concat agent-key ".jsonl") subs-dir))
                   (meta      (json-read-file meta-file))
                   (mtime     (when (file-exists-p jsonl)
                                (float-time (file-attribute-modification-time
                                             (file-attributes jsonl))))))
              (push (list :agent-id   agent-key
                          :agent-type (cdr (assq 'agentType   meta))
                          :description (cdr (assq 'description meta))
                          :mtime      (or mtime 0)
                          :jsonl-file (when (file-exists-p jsonl) jsonl))
                    result))
          (error nil))))
    (nreverse result)))

;;; Session-file lookup ────────────────────────────────────────────────────────

(defun claude-panel--find-session-info (session-id)
  "Return (:project-dir NAME :file PATH) for SESSION-ID, or nil if not found."
  (catch 'found
    (dolist (proj (directory-files "~/.claude/projects/" nil "^[^.]" t))
      (let ((f (expand-file-name (concat session-id ".jsonl")
                                 (expand-file-name proj "~/.claude/projects/"))))
        (when (file-exists-p f)
          (throw 'found (list :project-dir proj :file f)))))
    nil))

;;; Status helpers ─────────────────────────────────────────────────────────────

(defun claude-panel--live-status (buffer)
  "Status string for a live agent-shell BUFFER."
  (if (fboundp 'agent-shell-manager--get-status)
      (agent-shell-manager--get-status buffer)
    (with-current-buffer buffer
      (cond ((not (get-buffer-process buffer)) "killed")
            ((and (fboundp 'shell-maker-busy) (shell-maker-busy)) "working")
            (t "ready")))))

(defun claude-panel--live-model (buffer)
  "Short model display name for live agent-shell BUFFER."
  (let ((mid (with-current-buffer buffer
               (and (boundp 'agent-shell--state)
                    (map-nested-elt agent-shell--state '(:session :model-id))))))
    (when mid
      (if (fboundp 'my/agent-shell-model-display-name)
          (my/agent-shell-model-display-name mid)
        mid))))

(defun claude-panel--status-icon-face (status)
  "Return (ICON . FACE) for STATUS string."
  (pcase status
    ("working"      '("●" . warning))
    ("waiting"      '("◑" . font-lock-keyword-face))
    ("ready"        '("○" . success))
    ("headless"     '("·" . shadow))
    ("active"       '("◐" . warning))
    ("initializing" '("…" . shadow))
    ("done"         '("✓" . shadow))
    ("killed"       '("×" . error))
    (_              '("?" . shadow))))

;;; Entry building ─────────────────────────────────────────────────────────────

(defun claude-panel--make-subagent-entries (subs cwd)
  "Convert SUBS plists into panel entry plists, omitting done subagents."
  (let* ((active (seq-filter
                  (lambda (sub)
                    (< (- (float-time) (plist-get sub :mtime))
                       claude-panel-subagent-active-threshold))
                  subs))
         (n (length active)))
    (cl-loop for sub in active
             for i from 1
             collect
             (list :id          (plist-get sub :agent-id)
                   :kind        'subagent
                   :status      "active"
                   :model       nil
                   :description (plist-get sub :description)
                   :cwd         cwd
                   :buffer      nil
                   :pid         nil
                   :jsonl-file  (plist-get sub :jsonl-file)
                   :depth       1
                   :tree-prefix (if (= i n) "└─ " "├─ ")
                   :agent-type  (plist-get sub :agent-type)))))

(defun claude-panel--build-entries ()
  "Return a flat list of entry plists grouped by directory, with dir headers."
  (let* ((raw-bufs (when (fboundp 'agent-shell-buffers) (agent-shell-buffers)))
         (live-bufs (cond
                     ((null raw-bufs) nil)
                     ((listp raw-bufs) (seq-filter #'buffer-live-p raw-bufs))
                     ((buffer-live-p raw-bufs) (list raw-bufs))))
         (live-sid-map (let ((ht (make-hash-table :test 'equal)))
                         (dolist (buf live-bufs)
                           (when-let ((sid (with-current-buffer buf
                                             (and (boundp 'agent-shell--state)
                                                  (map-nested-elt agent-shell--state
                                                                  '(:session :id))))))
                             (puthash sid buf ht)))
                         ht))
         (running (when (fboundp 'my/claude-running-sessions)
                    (my/claude-running-sessions)))
         (saved-list (when (fboundp 'my/claude-saved-sessions)
                       (my/claude-saved-sessions 100)))
         (saved-map (let ((ht (make-hash-table :test 'equal)))
                      (dolist (s saved-list) (puthash (plist-get s :session-id) s ht))
                      ht))
         (desc-cache (and (boundp 'my/claude-desc-cache) my/claude-desc-cache))
         ;; Each element: (root-entry . subagent-entries)
         root-groups)

    ;; ── Live buffers ──────────────────────────────────────────────────────────
    (dolist (buf live-bufs)
      (let* ((sid      (with-current-buffer buf
                         (and (boundp 'agent-shell--state)
                              (map-nested-elt agent-shell--state '(:session :id)))))
             (info     (or (and sid (gethash sid saved-map))
                           (and sid (claude-panel--find-session-info sid))))
             (proj-dir (plist-get info :project-dir))
             (jsonl    (plist-get info :file))
             (status   (claude-panel--live-status buf))
             (model    (claude-panel--live-model buf))
             (cwd      (with-current-buffer buf default-directory))
             (desc     (and sid desc-cache (gethash sid desc-cache)))
             (subs     (when (and sid proj-dir)
                         (claude-panel--subagents sid proj-dir)))
             (root     (list :id sid :kind 'live :status status :model model
                             :description desc :cwd cwd :buffer buf
                             :jsonl-file jsonl :depth 0 :tree-prefix "")))
        (push (cons root (claude-panel--make-subagent-entries subs cwd))
              root-groups)))

    ;; ── Headless processes ────────────────────────────────────────────────────
    (dolist (r running)
      (let* ((sid (plist-get r :session-id))
             (pid (plist-get r :pid))
             (cwd (plist-get r :cwd)))
        (unless (gethash sid live-sid-map)
          (when (= 0 (call-process "kill" nil nil nil "-0" pid))
            (let* ((info     (or (gethash sid saved-map)
                                 (claude-panel--find-session-info sid)))
                   (proj-dir (plist-get info :project-dir))
                   (jsonl    (plist-get info :file))
                   (desc     (and desc-cache (gethash sid desc-cache)))
                   (subs     (when (and sid proj-dir)
                               (claude-panel--subagents sid proj-dir)))
                   (root     (list :id sid :kind 'run :status "headless" :model nil
                                   :description desc :cwd cwd :buffer nil :pid pid
                                   :jsonl-file jsonl :depth 0 :tree-prefix "")))
              (push (cons root (claude-panel--make-subagent-entries subs cwd))
                    root-groups))))))

    ;; ── Group by directory and flatten with headers ───────────────────────────
    (let* ((groups-rev (nreverse root-groups))
           ;; alist: cwd -> list of (root . subs) in order
           (dir-groups (let ((ht (make-hash-table :test 'equal))
                             order)
                         (dolist (pair groups-rev)
                           (let ((cwd (plist-get (car pair) :cwd)))
                             (unless (gethash cwd ht)
                               (push cwd order))
                             (puthash cwd (append (gethash cwd ht) (list pair)) ht)))
                         (cons ht (nreverse order))))
           (dir-ht    (car dir-groups))
           (dir-order (cdr dir-groups))
           result)
      (dolist (cwd dir-order)
        (let ((pairs (gethash cwd dir-ht)))
          ;; Directory header row
          (push (list :kind 'dir-header :cwd cwd) result)
          ;; Root entries + their subagents
          (dolist (pair pairs)
            (push (car pair) result)
            (dolist (sub (cdr pair))
              (push sub result)))))
      (nreverse result))))

;;; Row formatting ─────────────────────────────────────────────────────────────

(defun claude-panel--make-row (entry)
  "Convert ENTRY plist to a (ID COLUMNS-VECTOR) tabulated-list row."
  (if (eq (plist-get entry :kind) 'dir-header)
      ;; Directory separator row
      (let* ((bar  (make-string (max 0 (- (frame-width) 4)) ?─))
             (text (propertize bar 'face 'shadow)))
        (list entry (vector text "" "")))
    ;; Normal agent/subagent row
    (let* ((depth    (plist-get entry :depth))
           (prefix   (plist-get entry :tree-prefix))
           (status   (or (plist-get entry :status) "?"))
           (ic+face  (claude-panel--status-icon-face status))
           (icon     (propertize (car ic+face) 'face (cdr ic+face)))
           (cwd      (plist-get entry :cwd))
           (atype    (plist-get entry :agent-type))
           (label    (if (zerop depth)
                         (or (and cwd (file-name-nondirectory
                                       (directory-file-name cwd)))
                             "?")
                       (or atype "agent")))
           (desc     (plist-get entry :description))
           (core     (concat prefix icon " " label))
           (room     (max 0 (- 36 (length core))))
           (desc-str (if (and desc (> room 4))
                         (let ((s (replace-regexp-in-string "[\n\r]+" " " desc)))
                           (propertize
                            (concat "  " (if (> (length s) room)
                                            (concat (substring s 0 (max 0 (- room 3))) "…")
                                          s))
                            'face 'shadow))
                       ""))
           (name-col   (concat core desc-str))
           (status-col (propertize status 'face (cdr ic+face)))
           (model-col  (or (plist-get entry :model) "")))
      (list entry (vector name-col status-col model-col)))))

;;; Preview window ─────────────────────────────────────────────────────────────

(defun claude-panel--ensure-preview-window ()
  "Create the preview side-window if it isn't already visible."
  (unless (and claude-panel--preview-buffer
               (buffer-live-p claude-panel--preview-buffer))
    (setq claude-panel--preview-buffer (get-buffer-create "*claude-panel-preview*"))
    (with-current-buffer claude-panel--preview-buffer
      (setq buffer-read-only t
            mode-line-format nil
            header-line-format (propertize " Preview" 'face 'shadow))))
  (unless (get-buffer-window claude-panel--preview-buffer)
    (condition-case nil
        (display-buffer-in-side-window
         claude-panel--preview-buffer
         `((side . right)
           (slot . 1)
           (window-width . ,claude-panel-preview-width)
           (window-parameters
            . ((no-other-window . t)
               (no-delete-other-windows . t)))))
      (error nil))))

(defvar-local claude-panel--last-preview-id nil
  "ID of the last entry rendered in preview, to avoid redundant renders.")

(defvar claude-panel--preview-process nil
  "Running async preview process, if any.")

(defconst claude-panel--preview-py
  (mapconcat #'identity
             '("import json,sys"
               "msgs=[]"
               "for l in open(sys.argv[1]):"
               " try:"
               "  o=json.loads(l)"
               "  if o.get('type') in ('user','assistant'):"
               "   r=o.get('message',{}).get('role','')"
               "   c=o.get('message',{}).get('content','')"
               "   if isinstance(c,list):"
               "    t=' '.join(x.get('text','') for x in c if isinstance(x,dict) and x.get('type')=='text')"
               "   else:"
               "    t=str(c)"
               "   if t.strip():msgs.append((r,t[:500]))"
               " except:pass"
               "for r,t in msgs[-8:]:"
               " print(r.upper())"
               " print(t)"
               " print()")
             "\n")
  "Python snippet for extracting preview messages from a JSONL file.")

(defun claude-panel--update-preview ()
  "Refresh the preview pane for the entry at point."
  (when (derived-mode-p 'claude-panel-mode)
    (when-let ((entry (tabulated-list-get-id)))
      (let ((id (plist-get entry :id)))
        (unless (equal id claude-panel--last-preview-id)
          (setq claude-panel--last-preview-id id)
          (claude-panel--ensure-preview-window)
          (when (and claude-panel--preview-buffer
                     (buffer-live-p claude-panel--preview-buffer))
            (let* ((buf        (plist-get entry :buffer))
                   (jsonl-file (plist-get entry :jsonl-file)))
              (cond
               ;; Live agent-shell buffer: direct copy, no subprocess needed
               ((and buf (buffer-live-p buf))
                (with-current-buffer claude-panel--preview-buffer
                  (let ((inhibit-read-only t))
                    (erase-buffer)
                    (insert (with-current-buffer buf
                              (buffer-substring
                               (max (point-min) (- (point-max) 4000))
                               (point-max))))
                    (goto-char (point-max)))))
               ;; Headless/subagent: async Python parse
               ((and jsonl-file (file-exists-p jsonl-file))
                (when (process-live-p claude-panel--preview-process)
                  (delete-process claude-panel--preview-process))
                (let ((target-buf claude-panel--preview-buffer)
                      (tmp-buf (get-buffer-create " *claude-panel-preview-tmp*")))
                  (with-current-buffer tmp-buf (erase-buffer))
                  (setq claude-panel--preview-process
                        (make-process
                         :name     "claude-panel-preview"
                         :buffer   tmp-buf
                         :command  (list "python3" "-c" claude-panel--preview-py jsonl-file)
                         :noquery  t
                         :sentinel (lambda (proc _event)
                                     (when (and (eq (process-status proc) 'exit)
                                                (buffer-live-p target-buf))
                                       (let ((output (with-current-buffer (process-buffer proc)
                                                       (buffer-string))))
                                         (with-current-buffer target-buf
                                           (let ((inhibit-read-only t))
                                             (erase-buffer)
                                             (insert output)
                                             (goto-char (point-max)))))))))))
               (t
                (with-current-buffer claude-panel--preview-buffer
                  (let ((inhibit-read-only t))
                    (erase-buffer)
                    (insert (propertize "(no preview available)" 'face 'shadow)))))))))))))

;;; Mode ───────────────────────────────────────────────────────────────────────

(defvar claude-panel-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "RET")     #'claude-panel-open-at-point)
    (define-key map (kbd "g")       #'claude-panel-refresh)
    (define-key map (kbd "k")       #'claude-panel-kill-at-point)
    (define-key map (kbd "C-c C-c") #'claude-panel-interrupt-at-point)
    (define-key map (kbd "q")       #'quit-window)
    map))


(defun claude-panel-help ()
  "Show a keybinding reference buffer for the Claude panel."
  (interactive)
  (with-help-window "*claude-panel-help*"
    (with-current-buffer "*claude-panel-help*"
      (insert "\n")
      (insert (propertize "  Claude Panel — Keybindings\n\n" 'face '(:weight bold :height 1.1)))
      (cl-flet ((row (key desc)
                  (insert (propertize (format "  %-18s" key) 'face 'font-lock-keyword-face))
                  (insert (format "%s\n" desc))))
        (row "RET"       "Open session (live buffer or resume)")
        (row "f"         "Preview transcript at point")
        (row "k"         "Kill process or buffer at point")
        (row "C-c C-c"   "Interrupt agent at point")
        (row "g"         "Refresh panel")
        (row "q"         "Close panel")
        (row "h"         "Show this help"))
      (insert "\n")
      (insert (propertize "  Press q to dismiss this window.\n" 'face 'shadow)))))

(define-derived-mode claude-panel-mode tabulated-list-mode "Agents"
  "Major mode for the Claude active-agents panel."
  (setq tabulated-list-format
        [("Agent"  38 nil)
         ("Status" 10 nil)
         ("Model"  17 nil)])
  (setq tabulated-list-padding 1)
  (setq tabulated-list-sort-key nil)
  (tabulated-list-init-header)
  (when claude-panel--timer
    (cancel-timer claude-panel--timer))
  (setq claude-panel--timer
        (run-with-idle-timer claude-panel-refresh-interval
                             claude-panel-refresh-interval
                             #'claude-panel--auto-refresh))
  (add-hook 'kill-buffer-hook #'claude-panel--on-kill nil t))

(define-key claude-panel-mode-map (kbd "RET")     #'claude-panel-open-at-point)
(define-key claude-panel-mode-map (kbd "k")       #'claude-panel-kill-at-point)
(define-key claude-panel-mode-map (kbd "C-c C-c") #'claude-panel-interrupt-at-point)
(define-key claude-panel-mode-map (kbd "g")       #'claude-panel-refresh)
(define-key claude-panel-mode-map (kbd "f")       #'claude-panel-preview-at-point)
(define-key claude-panel-mode-map (kbd "q")       #'quit-window)
(define-key claude-panel-mode-map (kbd "h")       #'claude-panel-help)

(defun claude-panel--on-kill ()
  (when claude-panel--timer
    (cancel-timer claude-panel--timer)
    (setq claude-panel--timer nil))
  (when (and claude-panel--preview-buffer (buffer-live-p claude-panel--preview-buffer))
    (when-let ((w (get-buffer-window claude-panel--preview-buffer)))
      (delete-window w))
    (kill-buffer claude-panel--preview-buffer)
    (setq claude-panel--preview-buffer nil)))

(defun claude-panel--auto-refresh ()
  (when (and claude-panel--buffer
             (buffer-live-p claude-panel--buffer)
             (get-buffer-window claude-panel--buffer))
    (with-current-buffer claude-panel--buffer
      (let ((saved-id (when-let ((e (tabulated-list-get-id)))
                        (plist-get e :id))))
        (claude-panel-refresh)
        (when saved-id
          (goto-char (point-min))
          (while (and (not (eobp))
                      (not (when-let ((e (tabulated-list-get-id)))
                             (equal (plist-get e :id) saved-id))))
            (forward-line 1)))))))

;;; Actions ────────────────────────────────────────────────────────────────────

(defun claude-panel-refresh ()
  "Rebuild the panel entry list."
  (interactive)
  (when (and claude-panel--buffer (buffer-live-p claude-panel--buffer))
    (with-current-buffer claude-panel--buffer
      (setq claude-panel--last-preview-id nil)
      (setq tabulated-list-entries
            (mapcar #'claude-panel--make-row (claude-panel--build-entries)))
      (tabulated-list-print t))))

(defun claude-panel-preview-at-point ()
  "Open the preview pane and show transcript for the entry at point."
  (interactive)
  (setq claude-panel--last-preview-id nil)
  (claude-panel--ensure-preview-window)
  (claude-panel--update-preview))

(defun claude-panel-open-at-point ()
  "Switch to the live buffer at point, or resume session in a new agent-shell."
  (interactive)
  (when-let ((entry (tabulated-list-get-id)))
    (if (eq (plist-get entry :kind) 'subagent)
        (message "Subagent — no interactive buffer")
      (let* ((buf (plist-get entry :buffer))
             (sid (plist-get entry :id)))
        (cond
         ((and buf (buffer-live-p buf))
          (if-let ((win (get-buffer-window buf t)))
              (select-window win)
            (switch-to-buffer-other-window buf)))
         ((and sid (fboundp 'agent-shell-resume-session))
          (agent-shell-resume-session sid))
         (t
          (message "No session ID to resume")))))))

(defun claude-panel-kill-at-point ()
  "Kill process or buffer at point."
  (interactive)
  (when-let ((entry (tabulated-list-get-id)))
    (let* ((pid (plist-get entry :pid))
           (buf (plist-get entry :buffer)))
      (cond
       (pid
        (when (yes-or-no-p (format "Send SIGTERM to process %s? " pid))
          (signal-process (string-to-number pid) 'SIGTERM)
          (run-with-timer 0.5 nil #'claude-panel-refresh)))
       ((and buf (buffer-live-p buf))
        (when (yes-or-no-p (format "Kill buffer %s? " (buffer-name buf)))
          (kill-buffer buf)
          (claude-panel-refresh)))
       (t
        (message "Nothing to kill at point"))))))

(defun claude-panel-interrupt-at-point ()
  "Interrupt the agent at point."
  (interactive)
  (when-let ((entry (tabulated-list-get-id)))
    (when-let ((buf (plist-get entry :buffer)))
      (if (buffer-live-p buf)
          (with-current-buffer buf
            (if (fboundp 'agent-shell-interrupt)
                (agent-shell-interrupt)
              (message "agent-shell-interrupt not available")))
        (message "Buffer no longer live")))))

;;; Toggle / display ───────────────────────────────────────────────────────────

(defun claude-panel-toggle ()
  "Toggle the Claude active-agent panel side window."
  (interactive)
  (if (and claude-panel--buffer
           (buffer-live-p claude-panel--buffer)
           (get-buffer-window claude-panel--buffer))
      (progn
        (when (and claude-panel--preview-buffer
                   (buffer-live-p claude-panel--preview-buffer)
                   (get-buffer-window claude-panel--preview-buffer))
          (delete-window (get-buffer-window claude-panel--preview-buffer)))
        (delete-window (get-buffer-window claude-panel--buffer)))
    (claude-panel--open)))

(defun claude-panel--open ()
  "Create (if needed) and display the panel."
  (unless (and claude-panel--buffer (buffer-live-p claude-panel--buffer))
    (setq claude-panel--buffer (get-buffer-create "*claude-panel*"))
    (with-current-buffer claude-panel--buffer
      (claude-panel-mode)))
  (claude-panel-refresh)
  (let ((win (display-buffer-in-side-window
              claude-panel--buffer
              `((side . bottom)
                (slot . 1)
                (window-height . ,claude-panel-height)
                (window-parameters
                 . ((no-other-window . t)
                    (no-delete-other-windows . t)))))))
    (select-window win)))

(provide 'claude-panel)
;;; claude-panel.el ends here
