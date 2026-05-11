;; -*- lexical-binding: t -*-

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
(use-package agent-shell
  :ensure t
  :bind (("C-c a" . my/agent-shell-start)
         ("C-c A" . my/agent-shell-start-in-dir)
         ("C-x C-r" . agent-shell-restart))
  :hook (agent-shell-mode . (lambda ()
			      (local-set-key (kbd "M-a") #'move-beginning-of-line)
			      (setq-local comint-scroll-to-bottom-on-output 'all)))
  :custom
  (agent-shell-cursor-acp-command '("cursor-agent" "acp"))
  (agent-shell-thought-process-expand-by-default t)
  :config
  (setq agent-shell-show-welcome-message nil)
  (setq agent-shell-header-style nil)
  (setq agent-shell-confirm-interrupt nil)
  (advice-add 'agent-shell--make-header-model :filter-return
              (lambda (result)
                (when-let ((model-id (map-elt result :model-id)))
                  (map-put! result :model-name model-id))
                result)))

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

(defvar-local my/agent-history-shown nil)
(defvar my/agent-shell-suppress-next-transcript nil)

(advice-add 'agent-shell-restart :before
            (lambda (&rest args)
              (setq my/agent-shell-suppress-next-transcript
                    (null (plist-get args :session-id))))
            '((name . my/agent-shell-suppress-transcript-on-fresh-restart)))

(defun my/agent-shell-maybe-show-prev-transcript ()
  (when (and (derived-mode-p 'agent-shell-mode)
             (not (shell-maker-busy))
             (not my/agent-history-shown)
             (map-nested-elt agent-shell--state '(:session :id)))
    (setq my/agent-history-shown t)
    (let ((suppress my/agent-shell-suppress-next-transcript))
      (setq my/agent-shell-suppress-next-transcript nil)
      (unless suppress
        (condition-case nil
            (let* ((cwd (agent-shell-cwd))
                   (dir (expand-file-name ".agent-shell/transcripts" cwd))
                   (current agent-shell--transcript-file)
                   (all (when (file-directory-p dir)
                          (sort (directory-files dir t "\\.md$") #'string<)))
                   (prev (car (last (cl-remove-if
                                     (lambda (f) (string= f current))
                                     all)))))
              (when (and prev (file-exists-p prev))
                (let ((content (with-temp-buffer
                                 (insert-file-contents prev)
                                 (buffer-string)))
                      (inhibit-read-only t))
                  (save-excursion
                    (goto-char (point-min))
                    (insert (propertize
                             (concat content "\n\n")
                             'read-only t
                             'font-lock-face 'shadow))))))
          (error nil))))))

(add-hook 'agent-shell-mode-hook
          (lambda ()
            (setq-local my/agent-history-shown nil)
            (add-hook 'post-command-hook
                      #'my/agent-shell-maybe-show-prev-transcript nil t)))

(use-package agent-shell-macext
  :vc (:url "https://github.com/cxa/agent-shell-macext" :rev :newest)
  :after agent-shell
  :hook (agent-shell-mode . agent-shell-macext-setup)
  :custom
  (agent-shell-macext-file-copy-policy 'auto)
  (agent-shell-macext-notifications t)
  (agent-shell-macext-notify-current-buffer nil))

(provide 'my-agent-shell)
