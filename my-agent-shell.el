;; -*- lexical-binding: t -*-

(declare-function agent-shell-start "agent-shell")
(declare-function agent-shell--state "agent-shell")
(declare-function agent-shell--enqueue-request "agent-shell")
(declare-function agent-shell-ui-toggle-fragment-at-point "agent-shell")
(declare-function shell-maker-busy "shell-maker")
(declare-function shell-maker-submit "shell-maker")
(declare-function shell-maker--prompt-begin-position "shell-maker")
(declare-function agent-shell-anthropic-start-claude-code "agent-shell-anthropic")
(declare-function agent-shell-anthropic-make-claude-code-config "agent-shell-anthropic")

(use-package agent-shell
  :ensure t
  :bind ("C-x C-r" . agent-shell-restart)
  :hook (agent-shell-mode . (lambda ()
			      (local-set-key (kbd "M-a") #'move-beginning-of-line)
			      (setq-local comint-scroll-to-bottom-on-output 'all)))
  :custom
  (agent-shell-cursor-acp-command '("cursor-agent" "acp"))
  (agent-shell-thought-process-expand-by-default t)
  (agent-shell-show-welcome-message nil)
  (agent-shell-header-style nil)
  (agent-shell-confirm-interrupt nil)
  :config
  (advice-add 'agent-shell--make-header-model :filter-return
              (lambda (result)
                (when-let ((model-id (map-elt result :model-id)))
                  (map-put! result :model-name model-id))
                result)))

(defun my/agent-shell-start ()
  "Start agent shell in `default-directory'."
  (interactive)
  (agent-shell-anthropic-start-claude-code))

(defun my/agent-shell-start-in-dir (dir)
  "Start agent shell in a prompted directory."
  (interactive "DStart agent in: ")
  (let ((default-directory dir))
    (agent-shell-anthropic-start-claude-code)))

;; cursor-agent >= 2026.04 speaks ACP natively via `cursor-agent acp`,
;; so we skip the flaky cursor-agent-acp npm shim and talk to the CLI directly.
;; See https://cursor.com/docs/cli/acp

(defvar-local my/agent-pending-input "")
(defvar-local my/agent-pending-overlay nil)

(defun my/agent-pending-display ()
  (when (derived-mode-p 'agent-shell-mode)
    (if (string-empty-p my/agent-pending-input)
        (when my/agent-pending-overlay
          (delete-overlay my/agent-pending-overlay)
          (setq my/agent-pending-overlay nil))
      (let ((pos (min (point-max) (window-end nil t))))
        (unless my/agent-pending-overlay
          (setq my/agent-pending-overlay (make-overlay pos pos nil t t)))
        (move-overlay my/agent-pending-overlay pos pos)
        (overlay-put my/agent-pending-overlay 'after-string
                     (concat
                      (propertize "\n" 'face 'default)
                      (propertize (concat "  ❯ " my/agent-pending-input "█  ")
                                  'face '(:background "#1a2e44"
                                          :foreground "#aac8ff"
                                          :box (:line-width (6 . 6) :color "#1a2e44")
                                          :extend t))))))))

(defun my/agent-pending-reanchor ()
  (when (and (derived-mode-p 'agent-shell-mode)
             my/agent-pending-overlay
             (not (string-empty-p my/agent-pending-input)))
    (let ((pos (min (point-max) (window-end nil t))))
      (move-overlay my/agent-pending-overlay pos pos))))

(with-eval-after-load 'agent-shell-anthropic
  (advice-add 'agent-shell-anthropic-make-claude-code-config
              :filter-return
              (lambda (config)
                (map-put! config :shell-prompt "❯ ")
                (map-put! config :shell-prompt-regexp "❯ ")
                config)))

(defun my/agent-shell-busy-self-insert (n &optional c)
  (interactive "p")
  (if (and (derived-mode-p 'agent-shell-mode)
           (or (shell-maker-busy) (not (string-empty-p my/agent-pending-input))))
      (progn
        (setq my/agent-pending-input
              (concat my/agent-pending-input
                      (make-string n (or c last-command-event))))
        (my/agent-pending-display))
    (self-insert-command n c)))

(defun my/agent-shell-busy-backspace ()
  (interactive)
  (if (and (derived-mode-p 'agent-shell-mode)
           (or (shell-maker-busy) (not (string-empty-p my/agent-pending-input))))
      (unless (string-empty-p my/agent-pending-input)
        (setq my/agent-pending-input (substring my/agent-pending-input 0 -1))
        (my/agent-pending-display))
    (call-interactively #'backward-delete-char-untabify)))

(defun my/agent-shell-collapse-thinking-blocks ()
  (when (derived-mode-p 'agent-shell-mode)
    (let ((pos (point-min)))
      (while (and pos (< pos (point-max)))
        (let ((state (get-text-property pos 'agent-shell-ui-state)))
          (when (and state
                     (string-suffix-p "agent_thought_chunk"
                                      (or (map-elt state :qualified-id) ""))
                     (not (map-elt state :collapsed)))
            (save-excursion
              (goto-char pos)
              (agent-shell-ui-toggle-fragment-at-point))))
        (setq pos (next-single-property-change
                   pos 'agent-shell-ui-state nil (point-max)))))))

(defun my/agent-shell-submit-or-queue ()
  "Submit input normally, or hand pending input to agent-shell's queue if busy."
  (interactive)
  (if (and (derived-mode-p 'agent-shell-mode) (shell-maker-busy))
      (let ((text (string-trim my/agent-pending-input)))
        (unless (string-empty-p text)
          (setq my/agent-pending-input "")
          (my/agent-pending-display)
          (agent-shell--enqueue-request :prompt text)))
    (my/agent-shell-collapse-thinking-blocks)
    (shell-maker-submit)))

(defvar agent-shell-mode-map)

(with-eval-after-load 'agent-shell
  (keymap-set agent-shell-mode-map "RET" #'my/agent-shell-submit-or-queue)
  (keymap-set agent-shell-mode-map "<remap> <self-insert-command>"
              #'my/agent-shell-busy-self-insert)
  (keymap-set agent-shell-mode-map "<remap> <backward-delete-char-untabify>"
              #'my/agent-shell-busy-backspace)
  (keymap-set agent-shell-mode-map "<remap> <delete-backward-char>"
              #'my/agent-shell-busy-backspace)
  (keymap-set agent-shell-mode-map "C-n"
              (lambda (n)
                (interactive "^p")
                (unless (and my/agent-pending-overlay
                             (not (string-empty-p my/agent-pending-input))
                             (>= (point) (overlay-start my/agent-pending-overlay)))
                  (forward-line n)))))

(defun my/agent-shell-model-display-name (model-id)
  "Format `claude-sonnet-4-6[1m]' as `Sonnet 4.6'."
  (let* ((s (replace-regexp-in-string "^claude-" "" model-id))
         (s (replace-regexp-in-string "\\[.*?\\]" "" s))
         (s (replace-regexp-in-string "-[0-9]\\{8\\}.*" "" s))
         (parts (split-string s "-" t))
         (name (capitalize (car parts)))
         (ver (when (cdr parts) (mapconcat #'identity (cdr parts) "."))))
    (if ver (concat name " " ver) name)))

(defun my/agent-shell-mode-line-format-advice (orig-fn &rest args)
  (let ((result (apply orig-fn args)))
    (or (and result
             (condition-case nil
                 (when-let* ((state (agent-shell--state))
                             (model-id (map-nested-elt state '(:session :model-id)))
                             (short-name (or (map-elt (seq-find (lambda (m)
                                                                  (string= (map-elt m :model-id) model-id))
                                                                (map-nested-elt state '(:session :models)))
                                                      :name)
                                             model-id)))
                   (replace-regexp-in-string (regexp-quote short-name) model-id result t t))
               (error nil)))
        result)))

(with-eval-after-load 'agent-shell
  (advice-add 'agent-shell--mode-line-format :around #'my/agent-shell-mode-line-format-advice)

  (advice-add 'agent-shell--update-fragment :after
	      (lambda (&rest args)
		(let ((block-id (plist-get args :block-id))
		      (state    (plist-get args :state)))
		  (when (and block-id
			     (string-suffix-p "agent_thought_chunk" block-id)
			     state
			     (buffer-live-p (map-elt state :buffer)))
		    (with-current-buffer (map-elt state :buffer)
		      (save-excursion
			(goto-char (point-max))
			(when-let ((match (text-property-search-backward
					   'agent-shell-ui-state nil
					   (lambda (_ s)
					     (and s (string-suffix-p
						     "agent_thought_chunk"
						     (or (map-elt s :qualified-id) "")))))))
			  (let ((pos (prop-match-beginning match))
				(blk-end (prop-match-end match)))
			    (while (< pos blk-end)
			      (when (eq (get-text-property pos 'agent-shell-ui-section) 'body)
				(let* ((body-end (or (next-single-property-change
						      pos 'agent-shell-ui-section nil blk-end)
						     blk-end))
				       (ov (make-overlay pos body-end)))
				  (overlay-put ov 'face 'shadow)
				  (overlay-put ov 'priority 10)))
			      (setq pos (or (next-single-property-change
					     pos 'agent-shell-ui-section nil blk-end)
					    blk-end))))))))))))

(defvar-local my/agent-input-overlay nil)

(defun my/agent-shell-update-input-overlay ()
  (when (derived-mode-p 'agent-shell-mode)
    (condition-case nil
        (let* ((pos (shell-maker--prompt-begin-position))
               (nl (1- pos)))  ; newline just before the prompt
          (if (> nl (point-min))
              (progn
                (unless my/agent-input-overlay
                  (setq my/agent-input-overlay (make-overlay nl (1+ nl))))
                (move-overlay my/agent-input-overlay nl (1+ nl))
                (overlay-put my/agent-input-overlay 'face '(:background "#3a3a3a" :extend t))
                (overlay-put my/agent-input-overlay 'line-height 0.2))
            (when my/agent-input-overlay
              (delete-overlay my/agent-input-overlay)
              (setq my/agent-input-overlay nil))))
      (error nil))
    (my/agent-pending-reanchor)))

(defun my/agent-shell-setup-input-overlay ()
  (add-hook 'post-command-hook #'my/agent-shell-update-input-overlay nil t)
  (add-hook 'window-scroll-functions
            (lambda (_win _start) (my/agent-pending-reanchor)) nil t)
  (add-hook 'comint-output-filter-functions
            (lambda (_) (my/agent-pending-reanchor)) nil t))

(add-hook 'agent-shell-mode-hook #'my/agent-shell-setup-input-overlay)

(add-hook 'agent-shell-mode-hook
          (lambda ()
            (local-unset-key (kbd "M-p"))
            (add-hook 'isearch-mode-end-hook
                      (lambda ()
                        (when isearch-mode-end-hook-quit
                          (comint-kill-input)))
                      nil t)))

(defun my/consult-line-reveal-markdown-overlays (&rest _)
  (when (derived-mode-p 'agent-shell-mode)
    (remove-overlays (line-beginning-position) (line-end-position)
                     'category 'markdown-overlays)))

(advice-add 'consult-line :after #'my/consult-line-reveal-markdown-overlays)

(defcustom my/agent-shell-session-list-limit 50
  "Maximum number of past sessions shown in `my/agent-shell-pick-session'."
  :type 'integer
  :group 'agent-shell)

(defun my/agent-shell--prefetch-summaries (files)
  "Return alist of (FILE . plist) with :cwd :title :last-prompt for each in FILES.
Streams each JSONL line and captures the last `aiTitle' / `lastPrompt' seen
plus the first non-empty `cwd'."
  (when files
    (let* ((py "import json,sys
for p in sys.argv[1:]:
    t=lp=cwd=''
    try:
        for l in open(p):
            try:
                o=json.loads(l); tp=o.get('type')
                if tp=='ai-title':
                    v=o.get('aiTitle','')
                    if v: t=v
                elif tp=='last-prompt':
                    v=o.get('lastPrompt','')
                    if v: lp=v
                if not cwd:
                    c=o.get('cwd')
                    if c: cwd=c
            except: pass
    except: pass
    print('\\t'.join(s.replace(chr(10),' ').replace(chr(9),' ') for s in (t,lp,cwd)))")
           (cmd (concat "python3 -c " (shell-quote-argument py) " "
                        (mapconcat #'shell-quote-argument files " ")))
           (out (shell-command-to-string cmd))
           (lines (split-string out "\n")))
      (cl-mapcar (lambda (file line)
                   (let* ((parts (split-string line "\t"))
                          (title (string-trim (or (nth 0 parts) "")))
                          (lp (string-trim (or (nth 1 parts) "")))
                          (cwd (string-trim (or (nth 2 parts) ""))))
                     (cons file
                           (list :title (and (not (string-empty-p title)) title)
                                 :last-prompt (and (not (string-empty-p lp)) lp)
                                 :cwd (and (not (string-empty-p cwd)) cwd)))))
                 files lines))))

(defun my/agent-shell--read-session-summary (file)
  "Return plist (:session-id :cwd :title :last-prompt :mtime :file) or nil."
  (when-let ((info (cdr (assoc file
                               (my/agent-shell--prefetch-summaries (list file))))))
    (when (plist-get info :cwd)
      (list :session-id (file-name-base file)
            :cwd (plist-get info :cwd)
            :title (plist-get info :title)
            :last-prompt (plist-get info :last-prompt)
            :mtime (file-attribute-modification-time (file-attributes file))
            :file file))))

(defun my/agent-shell--list-sessions (&optional limit)
  "Return up to LIMIT session plists across `~/.claude/projects/*'.
Sorted by file mtime descending. LIMIT defaults to
`my/agent-shell-session-list-limit'."
  (let* ((limit (or limit my/agent-shell-session-list-limit))
         (root (expand-file-name "~/.claude/projects/"))
         (files (and (file-directory-p root)
                     (directory-files-recursively root "\\.jsonl\\'")))
         (sorted (sort files
                       (lambda (a b)
                         (time-less-p
                          (file-attribute-modification-time (file-attributes b))
                          (file-attribute-modification-time (file-attributes a))))))
         (top (seq-take sorted limit))
         (summaries (my/agent-shell--prefetch-summaries top)))
    (delq nil
          (mapcar (lambda (file)
                    (when-let* ((info (cdr (assoc file summaries)))
                                (cwd (plist-get info :cwd)))
                      (list :session-id (file-name-base file)
                            :cwd cwd
                            :title (plist-get info :title)
                            :last-prompt (plist-get info :last-prompt)
                            :mtime (file-attribute-modification-time
                                    (file-attributes file))
                            :file file)))
                  top))))

(defun my/agent-shell--live-sessions ()
  "Return live agent-shell sessions as plists of :session-id :cwd :buffer :mtime."
  (let (results)
    (dolist (buf (buffer-list))
      (when (and (buffer-live-p buf)
                 (with-current-buffer buf (derived-mode-p 'agent-shell-mode)))
        (when-let* ((state (buffer-local-value 'agent-shell--state buf))
                    (sid (map-nested-elt state '(:session :id))))
          (push (list :session-id sid
                      :cwd (buffer-local-value 'default-directory buf)
                      :buffer buf
                      :mtime (current-time))
                results))))
    results))

(defun my/agent-shell--format-session-entry (session &optional kind)
  "Format SESSION plist as a `completing-read' entry string.
KIND is `live' for open buffers, otherwise treated as saved."
  (let* ((cwd (plist-get session :cwd))
         (matches (and cwd
                       (string= (file-truename
                                 (file-name-as-directory cwd))
                                (file-truename
                                 (file-name-as-directory default-directory)))))
         (marker (cond ((eq kind 'live) "● ")
                       (matches "* ")
                       (t "  ")))
         (date (format-time-string "%Y-%m-%d %H:%M" (plist-get session :mtime)))
         (dir (if (and cwd (not (string-empty-p cwd)))
                  (file-name-nondirectory (directory-file-name cwd))
                "?"))
         (title (or (plist-get session :title) ""))
         (lp (or (plist-get session :last-prompt) ""))
         (joined (cond ((and (not (string-empty-p title))
                             (not (string-empty-p lp)))
                        (format "%s — %s" title lp))
                       ((not (string-empty-p title)) title)
                       ((not (string-empty-p lp)) lp)
                       (t "")))
         (desc (replace-regexp-in-string "[\n\t]+" " " joined))
         (desc (if (> (length desc) 80)
                   (concat (substring desc 0 79) "…")
                 desc)))
    (format "%s[%s]  %-22s  %s" marker date dir desc)))

(defun my/agent-shell-pick-session ()
  "Prompt for a Claude Code session: open buffer, saved, or `Start new session'.
Open buffers are switched to; saved sessions are resumed in a fresh buffer."
  (interactive)
  (let* ((all-saved (my/agent-shell--list-sessions))
         (saved-by-sid (let ((ht (make-hash-table :test 'equal)))
                         (dolist (s all-saved)
                           (puthash (plist-get s :session-id) s ht))
                         ht))
         (live (mapcar (lambda (l)
                         (if-let ((found (gethash (plist-get l :session-id)
                                                  saved-by-sid)))
                             (append l (list :title (plist-get found :title)
                                             :last-prompt (plist-get found :last-prompt)))
                           l))
                       (my/agent-shell--live-sessions)))
         (live-sids (mapcar (lambda (s) (plist-get s :session-id)) live))
         (saved (seq-remove (lambda (s)
                              (member (plist-get s :session-id) live-sids))
                            all-saved))
         (new-entry "▸ Start new session")
         (alist (append
                 (mapcar (lambda (s)
                           (cons (my/agent-shell--format-session-entry s 'live) s))
                         live)
                 (cons (cons new-entry nil)
                       (mapcar (lambda (s)
                                 (cons (my/agent-shell--format-session-entry s 'saved) s))
                               saved))))
         (display-strings (mapcar #'car alist))
         (choice (completing-read "Agent session: " display-strings
                                  nil t nil nil new-entry))
         (session (cdr (assoc choice alist))))
    (cond
     ((null session)
      (agent-shell-anthropic-start-claude-code))
     ((plist-get session :buffer)
      (switch-to-buffer (plist-get session :buffer)))
     (t
      (agent-shell-start
       :config (agent-shell-anthropic-make-claude-code-config)
       :session-id (plist-get session :session-id))))))

(keymap-global-set "C-c a" #'my/agent-shell-pick-session)
(keymap-global-set "C-c A" #'my/agent-shell-start-in-dir)

(use-package agent-shell-macext
  :vc (:url "https://github.com/cxa/agent-shell-macext" :rev :newest)
  :after agent-shell
  :hook (agent-shell-mode . agent-shell-macext-setup)
  :custom
  (agent-shell-macext-file-copy-policy 'auto)
  (agent-shell-macext-notifications t)
  (agent-shell-macext-notify-current-buffer nil))

(provide 'my-agent-shell)
