;; -*- lexical-binding: t -*-
;;; my-vterm.el --- vterm config and helpers

(defun dump-vterm-to-scratch ()
  "Copy current buffer to *scratch* without trailing empty lines, keeping colors."
  (interactive)

  (let* ((scratch-buf (get-buffer-create "*scratch*"))
         (content (buffer-substring (point-min) (point-max))))
    (with-current-buffer scratch-buf
      (goto-char (point-max))
      (insert content)
      (save-excursion
        (goto-char (point-max))
        (delete-blank-lines))
      (goto-char (point-max)))

    ;; 5. Switch focus to scratch
    (switch-to-buffer scratch-buf)
    (message "Vterm dumped and cleaned!")))

(use-package vterm
  :config
  ;; Set vterm text buffering delay
  (setq vterm-timer-delay 0.1)
  :bind (:map vterm-mode-map
	      ("M-0" . nil)
	      ("M-p" . nil)
	      ("M-'" . dump-vterm-to-scratch)
	      ("C-c d" . (lambda () (interactive)
			   (vterm-send-string (format-time-string "%Y-%m-%d"))))))

(defun vterm-at-current-location ()
  "Open a new vterm buffer in the current buffer's directory."
  (interactive)
  (let ((default-directory (file-truename default-directory)))
    (vterm)
    (my/vterm-rename-buffer-unique)))

(defun my/vterm-rename-buffer-unique ()
  "Rename current vterm buffer based on git repo/branch or directory, with unique suffix."
  (let* ((git-root (shell-command-to-string "git rev-parse --show-toplevel 2>/dev/null"))
         (git-root (string-trim git-root))
         (name (if (and git-root (not (string-empty-p git-root)))
                   (let ((repo (file-name-nondirectory git-root))
                         (branch (string-trim (shell-command-to-string "git branch --show-current 2>/dev/null"))))
                     (format "%s/%s" repo branch))
                 (file-name-nondirectory (directory-file-name default-directory)))))
    (rename-buffer (generate-new-buffer-name (format "*vterm: %s*" name)))))

(global-set-key (kbd "C-c t") 'vterm-at-current-location)

(defun my/vterm-update-buffer-and-directory (orig-func title)
  "Update vterm buffer name and `default-directory` from shell info.
Title format: `name|/path/to/dir' where name is repo/branch, cortex[conn] repo/branch, or dirname."
  (let* ((parts (split-string title "|"))
         (name-part (car parts))
         (dir-part (cadr parts)))
    ;; Update default-directory
    (when (and dir-part (file-directory-p dir-part))
      (cd-absolute dir-part))
    ;; Update buffer name (with unique suffix if collision)
    (when (and name-part (not (string-empty-p name-part)))
      (let ((new-name (format "*vterm: %s*" name-part)))
        (unless (string= (buffer-name) new-name)
          (rename-buffer (generate-new-buffer-name new-name))))))
  (funcall orig-func title))

(advice-add 'vterm--set-title :around #'my/vterm-update-buffer-and-directory)

(global-set-key (kbd "M-'") 'dump-vterm-to-scratch)

;; agent generated stuff to allow clicking on file paths in vterm
;; (commented out — timer errors polluting minibuffer)

;; (require 'vterm nil t)
;; (require 'easymenu)

;; ── Directory tracking ────────────────────────────────────────────────────
;;     (defvar-local vtermTZA-ls-dir nil)
;;     (add-hook 'vterm-directory-changed-hook
;;               (lambda () (setq vtermTZA-ls-dir default-directory)))

;; ── Track the buffer region vterm just rendered ───────────────────────────
;;     (defvar-local vtermTZA-update-start nil)
;;     (defvar-local vtermTZA-idle-timer   nil)

;;     (defun vtermTZA--before-update (&rest _)
;;       (unless vtermTZA-update-start
;;         (setq vtermTZA-update-start (point-max))))

;;     (defun vtermTZA--after-update (&rest _)
;;       (when vtermTZA-idle-timer
;;         (cancel-timer vtermTZA-idle-timer))
;;       (setq vtermTZA-idle-timer
;;             (run-with-idle-timer 0.2 nil #'vtermTZA--run-decoration (current-buffer))))

;;     (defun vtermTZA--run-decoration (buf)
;;       (when (buffer-live-p buf)
;;         (with-current-buffer buf
;;           (when (and vtermTZA-update-start
;;                  (<= vtermTZA-update-start (point-max)))
;; Don't touch the last line — that's the prompt where the cursor sits.
;; Decorating it clobbers vterm's cursor rendering.
;;             (let ((end (save-excursion
;;                          (goto-char (point-max))
;;                          (if (re-search-backward "\n" vtermTZA-update-start t)
;;                              (point)
;;                            vtermTZA-update-start))))
;;               (when (> end vtermTZA-update-start)
;;                 (vtermTZA-decorate-region vtermTZA-update-start end))))
;;           (setq vtermTZA-update-start nil
;;                 vtermTZA-idle-timer   nil))))

;;     (with-eval-after-load 'vterm
;;       (advice-add 'vterm--update :before #'vtermTZA--before-update)
;;       (advice-add 'vterm--update :after  #'vtermTZA--after-update))

;; ── Keymap (same shape as eshellTZA-ls-keymap) ───────────────────────────
;;     (defvar vtermTZA-ls-keymap
;;       (let ((map (make-sparse-keymap)))
;;         (define-key map (kbd "RET")       #'vtermTZA-open-menu-at-point)
;;         (define-key map (kbd "<return>")  #'vtermTZA-open-menu-at-point)
;;         (define-key map (kbd "<mouse-2>") #'vtermTZA-open-menu-at-mouse)
;;         map))

;; ── Post-render decoration: fixes both issues ─────────────────────────────
;;
;; Issue 1 (faces): add-face-text-property appends eshell-ls-normal
;;   (background only) without clobbering vterm's foreground colors.
;; Issue 2 (spaces in names): we stamp vtermTZA-ls-file on each token so
;;   vtermTZA-file-at-point reads the property instead of thing-at-point.

;;     (defun vtermTZA-decorate-region (beg end)
;;       "Stamp file-interaction text properties on file-name tokens in BEG..END."
;;       (let* ((dir (or vtermTZA-ls-dir default-directory)))
;;         (save-excursion
;;           (goto-char beg)
;;           (while (re-search-forward "[^[:space:]\n]+" end t)
;;             (let* ((token (match-string-no-properties 0))
;; ls appends * / = > @ | to flag file type
;;                    (fname (string-trim-right token "[*/=>@|]+"))
;;                    (ms    (match-beginning 0))
;;                    (me    (match-end 0)))
;;               (when (condition-case nil
;;                         (file-exists-p (expand-file-name fname dir))
;;                       (error nil))
;; Fix 1: background face composed on top of vterm's foreground
;;                   (add-face-text-property ms me 'eshell-ls-normal)
;; Fix 2: stamp the exact name so lookup never falls back to
;;        thing-at-point (which breaks on spaces)
;;                   (add-text-properties ms me
;;                     (list 'help-echo       "mouse-2: File Menu"
;;                           'mouse-face      'highlight
;;                           'keymap          vtermTZA-ls-keymap
;;                           'vtermTZA-ls-file fname
;;                           'vtermTZA-ls-dir  dir))))))))

;; ── File at point: property-first, thing-at-point fallback ───────────────
;;     (defun vtermTZA-file-at-point (&optional pos)
;;       (let* ((pos   (or pos (point)))
;;              (fname (or (get-text-property pos 'vtermTZA-ls-file)
;;                         (thing-at-point 'filename t)))
;;              (dir   (or (get-text-property pos 'vtermTZA-ls-dir)
;;                         vtermTZA-ls-dir
;;                         default-directory)))
;;         (when (and fname (not (string-empty-p (string-trim fname))))
;;           (expand-file-name (string-trim fname) dir))))

;; ── Popup menu ────────────────────────────────────────────────────────────
;;     (defvar vtermTZA-file-menu
;;       (let ((map (make-sparse-keymap "File Menu")))
;;         (easy-menu-add-item map nil ["Find File"           find-file                                       :keys ""])
;;         (easy-menu-add-item map nil ["Copy Absolute Path"  kill-new                                        :keys ""])
;;         (easy-menu-add-item map nil ["Copy Containing Dir" (lambda (f) (kill-new (file-name-directory f))) :keys ""])
;;         map))

;;     (defun vtermTZA-open-menu-at-point ()
;;       (interactive)
;;       (vtermTZA-open-menu (point)))

;;     (defun vtermTZA-open-menu-at-mouse (event)
;;       (interactive "e")
;;       (vtermTZA-open-menu event))

;;     (defun vtermTZA-open-menu (&optional event-or-pos)
;;       (unless event-or-pos (setq event-or-pos (point)))
;;       (let* ((event-posn (and (mouse-event-p event-or-pos) (event-end event-or-pos)))
;;              (pos        (if event-posn
;;                              (progn (select-window (posn-window event-posn))
;;                                     (posn-point event-posn))
;;                            event-or-pos))
;;              (abs-pos    (window-absolute-pixel-position pos))
;;              (popup-pos  (if (mouse-event-p event-or-pos)
;;                              event-or-pos
;;                            (list (list (car abs-pos) (cdr abs-pos)) (selected-window))))
;;              (path       (vtermTZA-file-at-point pos))
;;              (menu-item  (x-popup-menu popup-pos vtermTZA-file-menu))
;;              (fun        (and menu-item
;;                               (lookup-key vtermTZA-file-menu (apply #'vector menu-item)))))
;;         (when (and menu-item path (functionp fun))
;;           (funcall fun path))))

;; ── copy-mode keybindings (keyboard nav without mouse) ───────────────────
;;     (with-eval-after-load 'vterm
;;       (define-key vterm-copy-mode-map (kbd "RET")      #'vtermTZA-open-menu-at-point)
;;       (define-key vterm-copy-mode-map (kbd "<return>") #'vtermTZA-open-menu-at-point)
;;       (define-key vterm-copy-mode-map [mouse-2]        #'vtermTZA-open-menu-at-mouse))

(provide 'my-vterm)
;;; my-vterm.el ends here
