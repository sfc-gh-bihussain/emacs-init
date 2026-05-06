;; -*- lexical-binding: t -*-
;; todo bh:
;; c-x b and c-x c-b with preview so we can review all our ope nvterms and close them
;; agent shell keybinds:
;;reset context
;; switch working dir
;; look into the related packages,in https://github.com/xenodium/agent-shell
;;allow me to type a new msg while cur happening
;;see model name/effort

;; Refresher:
;; C-x C-e execute lisp
;; M-j execute and print on next line
;; M-: eval lisp in minibuffer
;; descibe function C-h f
;; descibe variable C-h v
;; describe package C-h p
;; C-x C--/+ to resize font

;; Possibly need to set the variables for a major mode before enabling the mode
;; TODO:
;; - A way to copy the nth line of the previous terminal command output
;; - faster way in vterm to enable copy mode


;;══════════════════════════════════════════════════════════════════════════════
;;  BOOTSTRAP
;;══════════════════════════════════════════════════════════════════════════════

(setq custom-file (concat user-emacs-directory "custom.el"))

(remove-hook 'kill-emacs-query-functions 'server-kill-emacs-query-function)

(if (eq system-type 'windows-nt)
    (setq shell-file-name "C:/cygwin64/bin/bash.exe"))

(when (file-exists-p custom-file)
  (load custom-file))

(setq mac-command-modifier 'meta)

(setq initial-scratch-message nil)

(setq-default message-log-max nil)

(defun my/insert-current-date ()
  "Insert the current date at point."
  (interactive)
  (insert (format-time-string "%Y-%m-%d")))

(global-set-key (kbd "C-c d") 'my/insert-current-date)


;; I commented this out on 2026-05-05 because i think i need this to see debug messages/warnings etc. from failing elisp commands
;; (if (get-buffer "*Messages*")
;;     (kill-buffer "*Messages*"))

(tooltip-mode 0) ; Mouse over tooltip

(global-auto-revert-mode)
(setq global-auto-revert-non-file-buffers t)

(winner-mode 1)
(desktop-save-mode 1)
(setq desktop-restore-eager 5)

(use-package persistent-scratch
  :config
  (persistent-scratch-setup-default)
  (persistent-scratch-autosave-mode 1))

(setq use-short-answers t)

(setq inhibit-startup-message t)
(server-start)
(setq backup-directory-alist (quote ((".*" . "~/.emacs_backups/"))))

(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents (package-refresh-contents))
(unless (package-installed-p 'use-package) (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(use-package exec-path-from-shell
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))

;; counsel/ivy in package-selected-packages activates ivy-mode via autoloads,
;; overriding vertico. Disable it immediately.
(when (fboundp 'ivy-mode) (ivy-mode -1))
(setq completing-read-function #'completing-read-default)


;;══════════════════════════════════════════════════════════════════════════════
;;  CORE KEYBINDINGS & UTILITIES
;;══════════════════════════════════════════════════════════════════════════════

(global-set-key (kbd "C-h C-e") 'package-list-packages)

(defun my/volatile-kill-buffer ()
  "Kill current buffer unconditionally."
  (interactive)
  (set-buffer-modified-p nil)
  (kill-buffer (current-buffer)))
;; Remove prompt to kill buffer with active process
(setq kill-buffer-query-functions (delq 'process-kill-buffer-query-function kill-buffer-query-functions))
;; Unconditionally kill unmodified buffers.
(global-set-key (kbd "C-x k") 'my/volatile-kill-buffer)

(defun my/open-init-file ()
  "Open the user's Emacs initialization file."
  (interactive)
  (find-file user-init-file))
(defun my/open-zshrc ()
  "Opens the current user's .zshrc file."
  (interactive)
  (find-file "~/.zshrc"))

(global-set-key (kbd "C-c i") 'my/open-init-file)
(global-set-key (kbd "C-c z") 'my/open-zshrc)

(use-package try)

(use-package command-log-mode
  :diminish
  :config
  (command-log-mode 1))


(global-set-key (kbd "C-s") 'consult-line)
(global-set-key (kbd "M-s M-s") 'consult-line-multi)
(global-set-key "\C-x\C-b" 'ibuffer)

(defun my/open-in-vscode ()
  "Open current file or dir in vscode.
URL `http://xahlee.info/emacs/emacs/emacs_open_in_vscode.html'

Version: 2020-02-13 2021-01-18 2022-08-04 2023-06-26"
  (interactive)
  (let ((xpath (if buffer-file-name buffer-file-name (expand-file-name default-directory))))
    (message "path is %s" xpath)
    (cond
     ((eq system-type 'darwin)
      (shell-command (format "open -a Visual\\ Studio\\ Code.app %s" (shell-quote-argument xpath))))
     ((eq system-type 'windows-nt)
      (shell-command (format "code.cmd %s" (shell-quote-argument xpath))))
     ((eq system-type 'gnu/linux)
      (shell-command (format "code %s" (shell-quote-argument xpath)))))))

(use-package posframe :ensure t)

(defun my/notify--hide ()
  (posframe-hide " *my-notify*")
  (remove-hook 'post-command-hook #'my/notify--hide))

(defun my/notify (msg)
  "Show MSG in a centered posframe popup; dismisses on next input or after 2s."
  (posframe-show " *my-notify*"
                 :string (concat "\n  " msg "  \n")
                 :poshandler #'posframe-poshandler-frame-center
                 ;;:timeout 2
                 :border-width 2
                 :border-color (face-attribute 'default :foreground)
                 :internal-border-width 8)
  (run-with-timer 0 nil (lambda ()
                          (add-hook 'post-command-hook #'my/notify--hide))))

(defun my/copy-to-clipboard (text msg)
  "Copy TEXT to clipboard and show MSG as a centered popup."
  (kill-new text)
  (my/notify msg))

(defun my/copy-buffer-file-name-to-clipboard ()
  "Copy the current buffer's file name (full path) to the clipboard."
  (interactive)
  (when buffer-file-name
    (my/copy-to-clipboard buffer-file-name
                          (format "Copied full path: %s" buffer-file-name))))

(defun my/copy-file-basename-to-clipboard ()
  "Copy the current buffer's file name (basename only) to the clipboard."
  (interactive)
  (when buffer-file-name
    (let ((basename (file-name-nondirectory buffer-file-name)))
      (my/copy-to-clipboard basename
                            (format "Copied filename: %s" basename)))))

(defun my/copy-region-as-xml ()
  "Copy the highlighted region wrapped in XML tags with full path and line numbers."
  (interactive)
  (if (use-region-p)
      (let* ((start      (region-beginning))
             (end        (region-end))
             (text       (buffer-substring-no-properties start end))
             (path       (or buffer-file-name (buffer-name)))
             (start-line (line-number-at-pos start))
             (end-line   (line-number-at-pos end))
             (xml        (format "<region path=\"%s\" start-line=\"%d\" end-line=\"%d\">\n%s\n</region>"
                                 path start-line end-line text)))
        (kill-new xml)
        (let* ((preview    (replace-regexp-in-string "\n" "↵" text))
	       (truncated  (if (> (length preview) 60)
			       (concat (substring preview 0 60) "…")
                             preview)))
          (my/notify (format "Copied %s:%d-%d\n  %s" path start-line end-line truncated))))
    (my/notify "No active region.")))

(global-set-key (kbd "C-c C-p") 'my/copy-file-basename-to-clipboard)
(global-set-key (kbd "C-c p")   'my/copy-buffer-file-name-to-clipboard)
(global-set-key (kbd "C-c r")   'my/copy-region-as-xml)

(defun my/revert-buffer-no-confirm ()
  "Revert buffer without confirmation."
  (interactive)
  (revert-buffer t t))

(setq select-enable-clipboard t)
(setq save-interprogram-paste-before-kill t)
(global-set-key (kbd "M-g M-g") 'my/revert-buffer-no-confirm)

(setq auto-save-file-name-transforms '((".*" "~/.emacs.d/autosaves/\\1" t)))

(unless (file-exists-p "~/.emacs.d/autosaves/")
  (make-directory "~/.emacs.d/autosaves/"))

(use-package ace-window
  :init
  (global-set-key (kbd "M-o") 'ace-window)
  :config
  (setq aw-dispatch-always t)
  (setq aw-keys '(?p ?w ?o ?q ?e ?r ?a ?k))
  :custom-face
  (aw-leading-char-face ((t (:foreground "OrangeRed" :weight bold :height 5.0))))
  (aw-background-face   ((t (:foreground "gray50"))))
  (aw-mode-line-face    ((t (:foreground "DeepSkyBlue" :weight bold)))))

(defun my/reload-init ()
  (interactive)
  (load-file user-init-file))
(global-set-key (kbd "<f5>") #'my/reload-init)


;;══════════════════════════════════════════════════════════════════════════════
;;  COMPLETION & NAVIGATION
;;══════════════════════════════════════════════════════════════════════════════

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package which-key
  :init
  (which-key-mode)
  (setq which-key-idle-delay 0.5)
  (setq which-key-idle-secondary-delay 0.05)
  :diminish which-key-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; STUFF POSSIBLY TO REMOVE
;; These are the defaults in 29 for me, idk why ppl set these lol
(column-number-mode 0) ; Numbers on bottom
(show-paren-mode 1)

;; Apparently IDO is old so it might be shit
;; Apparently IVY/HELM are the two most important ones
;; You can install both and use them in differenet contexts :o
;; Autocompletion
(ido-mode 0)
(put 'erase-buffer 'disabled nil)

;; https://kristofferbalintona.me/posts/202202211546/
(use-package general
  :ensure t)

(use-package marginalia
  :custom
  (marginalia-max-relative-age 600) ; show up to 10 mins ago
  (marginalia-align 'center)
  (marginalia-truncate-width (/ (window-width) 2))
  :init
  (marginalia-mode))

(use-package vertico
  :functions (vertico-directory-up)
  :custom
  (vertico-count 13)                    ; Number of candidates to display
  (vertico-resize t)
  (vertico-cycle nil) ; Go from last to first candidate and first to last (cycle)?
  :general
  (:keymaps 'vertico-map
            "<tab>" #'vertico-insert  ; Insert selected candidate into text area
            "<escape>" #'minibuffer-keyboard-quit ; Close minibuffer
            "C-g" #'abort-recursive-edit
            ;; NOTE 2022-02-05: Cycle through candidate groups
            "C-M-n" #'vertico-next-group
            "C-M-p" #'vertico-previous-group)
  :config
  (vertico-mode)
  (require 'vertico-directory)
  (keymap-set vertico-map "DEL"
              (lambda () (interactive)
                (or (vertico-directory-up) (delete-char -1)))))

(defun my/buffer-sort-mru-stars-last (candidates)
  "Preserve MRU order but push *special* buffers to the bottom."
  (let (regular stars)
    (dolist (c candidates)
      (if (and (> (length c) 0) (eq (aref c 0) ?*))
          (push c stars)
        (push c regular)))
    (nconc (nreverse regular) (nreverse stars))))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides
   `((file   (styles basic partial-completion))
     ;; Keep buffer-list's MRU-by-selection order for switch-to-buffer,
     ;; but push *special* buffers to the bottom.
     (buffer (display-sort-function . ,#'my/buffer-sort-mru-stars-last)
             (cycle-sort-function   . ,#'my/buffer-sort-mru-stars-last)))))

(setq read-buffer-completion-ignore-case t
      completion-ignore-case t)

;; Just to use consult theme to page thru themes while seeing them
(use-package consult
  :init
  (setq consult-find-args "find ."))


;;══════════════════════════════════════════════════════════════════════════════
;;  DEVELOPMENT
;;══════════════════════════════════════════════════════════════════════════════

(use-package lsp-java)

(add-hook 'java-mode-hook 'lsp-deferred)
(add-hook 'python-mode-hook 'lsp-deferred)
(add-hook 'csharp-mode-hook 'lsp-deferred)

;; Rebind C-c C-r in python-mode to use my/copy-region-as-xml
(defvar python-mode-map)
(with-eval-after-load 'python
  (define-key python-mode-map (kbd "C-c C-r") 'my/copy-region-as-xml))

(use-package yaml-mode)

(use-package treemacs
  :functions (doom-themes-treemacs-config)
  :config
  ;;(treemacs-follow-mode 0)
  ;;(treemacs-project-follow-mode)
  ;;(treemacs-display-current-project-exclusively)
  ;; use "doom-colors" for less minimal icon theme
  (setq treemacs-is-never-other-window t)
  (setq doom-themes-treemacs-enable-variable-pitch nil)
  (setq doom-themes-treemacs-theme "doom-colors")
  (doom-themes-treemacs-config)
  (treemacs-git-mode -1) ;; this was pausing rendering when i uodate branch with hundreds of thousands of line changes. i think if we change git mode to simple it might fix it too but i just disabled it for now
  ;;  (set-face-attribute 'treemacs-file-face nil :family "JetBrains Mono" :height 120)
  :bind
  (("M-0"       . treemacs-select-window)
   ("C-x t 1"   . treemacs-delete-other-windows)
   ("C-x t t"   . treemacs))
				; IDK Why this was here in my prev config
				;(:map treemacs-mode-map ("C-p" . treemacs-previous-line))
  )

(use-package blamer
  :custom
  (blamer-type 'visual)
  :config
  (add-hook 'sql-mode-hook 'blamer-mode)
  (add-hook 'prog-mode-hook 'blamer-mode))

(use-package ruff-format
  :config
  (add-hook 'python-mode-hook 'ruff-format-on-save-mode))

(use-package pyvenv
  :config
  (pyvenv-mode 1))

(use-package direnv
  :config
  (direnv-mode 1))

(use-package csv-mode)

(use-package dotenv-mode
  :config
  (add-to-list 'auto-mode-alist '("\\.env\\'" . dotenv-mode)))

(use-package dashboard
  :config
  (dashboard-setup-startup-hook)
  :custom
  (dashboard-items '((recents . 5)
                     (projects . 5))) ; Display 5 recent projects
  (dashboard-projects-backend 'projectile) ; Use Projectile for project lists
  (dashboard-banner-logo-title nil)
  (dashboard-startup-banner '("~/gifs/raiden_lets_dance_no_loop.gif")) ; Or nil for a list, or 'official for the Emacs logo
  (dashboard-center-content t)
  ;; vertically center content
  (dashboard-vertically-center-content t)
  (dashboard-icon-type 'nerd-icons)
  (dashboard-startupify-list '(dashboard-insert-banner
			       dashboard-insert-newline
			       dashboard-insert-banner-title
			       dashboard-insert-newline
			       dashboard-insert-navigator
			       dashboard-insert-newline
			       dashboard-insert-init-info
			       dashboard-insert-items
			       dashboard-insert-newline
			       dashboard-insert-footer)))

(use-package projectile
  :diminish
  :init
  (setq projectile-project-search-path
	'("~/code/"  "~/.emacs.d/" ))
  :config
  (global-set-key (kbd "M-p") 'projectile-command-map)
  (projectile-mode +1)
  (setq projectile-use-git-grep t)
  (setq projectile-switch-project-action 'projectile-run-vterm)
  (setq projectile-enable-caching t)
  (projectile-discover-projects-in-directory "~/code/")
  (projectile-discover-projects-in-directory "~/code/coco_crossing"))

(use-package magit)

;; Allow gpg signing in emacs
(use-package pinentry)
(pinentry-start)

(use-package why-this
  :config
  :diminish
  (global-why-this-mode t))


;;══════════════════════════════════════════════════════════════════════════════
;;  UI & THEMING
;;══════════════════════════════════════════════════════════════════════════════

;; Side bars
(set-fringe-mode 0)
(scroll-bar-mode 0)
(tool-bar-mode 0)
(menu-bar-mode 0)
;; Ugly way to hide top bar. TODO Is there a "mode?"
(push '(undecorated-round . t) default-frame-alist)
(setq visible-bell t)
(set-face-attribute 'default nil :font "JetBrains Mono")

;; Run at startup
(my/set-font-by-screen-size)

(use-package beacon
  :config
  (beacon-mode 1))

(use-package nerd-icons)
;; TODO BH
;; (if (not (find-font (font-spec :name "NFM")))
;;     (nerd-icons-install-fonts))

(use-package doom-themes
  :functions (doom-themes-visual-bell-config)
  :config
  (setq doom-themes-enable-bold t
	doom-themes-enable-italic t)
  ;; todo: try nier theme https://github.com/merrittlj/automata-theme
  (load-theme 'doom-peacock t)
  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config))

(setq custom-safe-themes t)
;; Doesn't work, but the intention was to enable automata theme
(use-package autothemer)
(use-package vertico-posframe)
(use-package nova
  :functions (nova-vertico-mode global-corfu-mode nova-corfu-mode)
  :vc (:url "https://github.com/thisisran/nova"
	    :rev "78c33f36b2ab9cc8b5925c57779d51fd2c1fc158")
  :config
  (require 'nova-vertico)
  (setq nova-vertico-depth-2-max-width (round (* (frame-width) 0.75)))
  (nova-vertico-mode 1)
  (require 'nova-corfu)
  (global-corfu-mode 1)
  (nova-corfu-mode 1))
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
;; Ghostty 0x96f port - swap the doom-peacock load above for this to use it:
;;   (load-theme '0x96f t)
(global-unset-key (kbd "M-t"))
(use-package theme-looper
  :config
  :bind
  ("M-t M-t" . theme-looper-enable-random-theme))

;; (add-hook 'emacs-startup-hook 'theme-looper-enable-random-theme)
;;(load-theme 'automata t)

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)
           (doom-modeline-buffer-encoding nil)))

;; (use-package spaceline
;;   :config (spaceline-emacs-theme))

;;; testing rounded fringes
(put 'downcase-region 'disabled nil)

(use-package default-text-scale
  :config (default-text-scale-mode))

(use-package expand-region
  :config
  (global-set-key (kbd "M-[") 'er/expand-region))

(use-package ultra-scroll
  :init
  (setq scroll-conservatively 3 ; or whatever value you prefer, since v0.4
        scroll-margin 0)        ; important: scroll-margin>0 not yet supported
  :config
  (ultra-scroll-mode 1)
  (setq pixel-scroll-precision-interpolate-page t)
  ;; not very high fps,  need natively built emacs emacs...
  (global-set-key [remap scroll-up-command] #'pixel-scroll-interpolate-down)
  (global-set-key [remap scroll-down-command] #'pixel-scroll-interpolate-up))

(load (expand-file-name "svg-line-numbers" user-emacs-directory))
(declare-function my/blend-colors "svg-line-numbers")

;; ── Rounded window top borders via SVG header line ───────────────────────────

(defvar my/win-border--cache (make-hash-table :test 'equal))

(defun my/win-border--clear-cache (&rest _)
  (clrhash my/win-border--cache))

(defun my/win-border--image (px-width)
  "Cached SVG rounded-top bar PX-WIDTH pixels wide."
  (or (gethash px-width my/win-border--cache)
      (let* ((h      12)
             (r      12)
             (kw     (face-attribute 'font-lock-keyword-face :foreground nil t))
             (color  (my/blend-colors "#ffffff" kw 0.3))
             (stroke (my/blend-colors "#ffffff" color 0.5))
             (svg    (svg-create px-width h)))
        (svg-rectangle svg 1 1 (- px-width 2) (+ h r)
                       :fill color
                       :stroke stroke
                       :stroke-width 1
                       :rx r :ry r)
        (let ((img (svg-image svg :scale 1.0 :ascent 'center)))
          (puthash px-width img my/win-border--cache)
          img))))

(defun my/win-border--header ()
  "Return a propertized string for `header-line-format'."
  (when (display-graphic-p)
    (when-let* ((win (get-buffer-window (current-buffer) t))
                (w   (window-pixel-width win)))
      (when (> w 0)
        (propertize " " 'display (my/win-border--image w))))))

(define-minor-mode my/window-border-mode
  "Show SVG rounded-top borders in window header lines."
  :global t
  :lighter ""
  :group 'emacs
  (if my/window-border-mode
      (progn
        (setq-default header-line-format '(:eval (my/win-border--header)))
        (add-hook 'window-size-change-functions #'my/win-border--clear-cache))
    (setq-default header-line-format nil)
    (remove-hook 'window-size-change-functions #'my/win-border--clear-cache)))

(defun my/win-border--set-local ()
  (setq-local header-line-format '(:eval (my/win-border--header))))

(defun my/win-border--after-agent-shell-header (&rest _)
  (when my/window-border-mode
    (setq header-line-format '(:eval (my/win-border--header)))))

(with-eval-after-load 'agent-shell
  (advice-add 'agent-shell--update-header-and-mode-line
              :after #'my/win-border--after-agent-shell-header))

(advice-add 'load-theme :after #'my/win-border--clear-cache)

(my/window-border-mode 1)

(use-package mini-frame
  :config
  (custom-set-variables
   '(mini-frame-show-parameters
     '((top . 10)
       (width . 0.7)
       (left . 0.5)))))


;;══════════════════════════════════════════════════════════════════════════════
;;  TERMINAL
;;══════════════════════════════════════════════════════════════════════════════

(load (expand-file-name "my-vterm.el" user-emacs-directory))

;;══════════════════════════════════════════════════════════════════════════════
;;  CLAUDE / AGENT-SHELL
;;══════════════════════════════════════════════════════════════════════════════

(defun my/claude-running-sessions ()
  "Return plist list of running claude processes with :session-id :pid :cwd.
Uses a single lsof call for all PIDs to avoid multiple shell round-trips."
  (let* ((ps-out (shell-command-to-string
                  "ps -eo pid,command | grep 'claude-agent-sdk.*--session-id' | grep -v grep"))
         pid-sid-list pids)
    (dolist (line (split-string ps-out "\n" t))
      (when (string-match "^ *\\([0-9]+\\).*--session-id \\([^ ]+\\)" line)
        (let ((pid (match-string 1 line))
              (sid (match-string 2 line)))
          (push (cons pid sid) pid-sid-list)
          (push pid pids))))
    (when pids
      ;; Single lsof call for all PIDs
      (let* ((lsof-out (shell-command-to-string
                        (format "lsof -p %s 2>/dev/null | awk '$4==\"cwd\"{print $2\" \"$9}'"
                                (string-join pids ","))))
             (cwd-map (make-hash-table :test 'equal)))
        (dolist (line (split-string lsof-out "\n" t))
          (when (string-match "^\\([0-9]+\\) \\(.*\\)" line)
            (puthash (match-string 1 line) (match-string 2 line) cwd-map)))
        (mapcar (lambda (ps)
                  (list :pid (car ps) :session-id (cdr ps)
                        :cwd (or (gethash (car ps) cwd-map) "")))
                pid-sid-list)))))

(defvar my/claude-desc-cache (make-hash-table :test 'equal)
  "Cache of session descriptions keyed by session-id.")

(defun my/claude-prefetch-descriptions (pairs)
  "Fetch descriptions for PAIRS (list of (session-id . filepath)) not yet cached.
Runs a single Python subprocess for all uncached files."
  (let ((uncached (seq-remove (lambda (p) (gethash (car p) my/claude-desc-cache)) pairs)))
    (when uncached
      (let* ((files (mapcar #'cdr uncached))
             (py "import json,sys\nfor p in sys.argv[1:]:\n t=lp=None\n try:\n  for l in open(p):\n   try:\n    o=json.loads(l);tp=o.get('type')\n    if tp=='ai-title':t=o.get('aiTitle','')\n    elif tp=='last-prompt':lp=o.get('lastPrompt','')\n   except:pass\n except:pass\n print((t or lp or '').replace(chr(10),' ')[:80])")
             (cmd (concat "python3 -c " (shell-quote-argument py) " "
                          (mapconcat #'shell-quote-argument files " ")))
             (out (shell-command-to-string cmd))
             (lines (split-string out "\n")))
        (cl-mapcar (lambda (pair line)
                     (puthash (car pair)
                              (let ((s (string-trim line))) (unless (string-empty-p s) s))
                              my/claude-desc-cache))
                   uncached lines)))))

(defun my/claude-saved-sessions (&optional limit)
  "Return plist list of saved sessions from ~/.claude/projects/, newest first.
Limits to LIMIT entries (default 40). Descriptions fetched in one Python call."
  (let ((projects-dir (expand-file-name "~/.claude/projects/"))
        (limit (or limit 40))
        all-files)
    (dolist (proj-dir (directory-files projects-dir t "^[^.]" t))
      (when (file-directory-p proj-dir)
        (dolist (sess-file (directory-files proj-dir t "\\.jsonl$" t))
          (push (cons (float-time (file-attribute-modification-time
                                   (file-attributes sess-file)))
                      (list :session-id (file-name-base sess-file)
                            :project-dir (file-name-nondirectory proj-dir)
                            :file sess-file))
                all-files))))
    (setq all-files (sort all-files (lambda (a b) (> (car a) (car b)))))
    (let* ((top (seq-take all-files limit))
           (sessions (mapcar #'cdr top))
           (pairs (mapcar (lambda (s) (cons (plist-get s :session-id) (plist-get s :file)))
                          sessions)))
      (my/claude-prefetch-descriptions pairs)
      (mapcar (lambda (s)
                (append s (list :description (gethash (plist-get s :session-id) my/claude-desc-cache))))
              sessions))))

(declare-function agent-shell-resume-session "my-agent-shell")
(defun my/claude-open-agent ()
  "Pick a running or saved Claude Code session and open in agent-shell."
  (interactive)
  (let* ((running (my/claude-running-sessions))
         (saved   (my/claude-saved-sessions))
         (running-ids (mapcar (lambda (r) (plist-get r :session-id)) running))
         (live-bufs (let ((ht (make-hash-table :test 'equal)))
                      (dolist (buf (buffer-list))
                        (when (with-current-buffer buf (derived-mode-p 'agent-shell-mode))
                          (when-let ((sid (map-nested-elt
                                          (buffer-local-value 'agent-shell--state buf)
                                          '(:session :id))))
                            (puthash sid buf ht))))
                      ht))
         candidates
         (meta (make-hash-table :test 'equal)))
    (dolist (r running)
      (let* ((sid  (plist-get r :session-id))
             (cwd  (plist-get r :cwd))
             (dir  (if (string-empty-p cwd) "?"
                     (file-name-nondirectory (directory-file-name cwd))))
             (buf  (gethash sid live-bufs))
             (tag  (if buf "LIVE" "RUN "))
             (desc (or (plist-get (seq-find (lambda (s) (equal (plist-get s :session-id) sid)) saved)
                                  :description) ""))
             (label (format "[%s] %s" tag dir)))
        (puthash label (list :kind (if buf 'live 'run) :session-id sid
                             :cwd cwd :buffer buf :description desc)
                 meta)
        (push label candidates)))
    (dolist (s saved)
      (let* ((sid  (plist-get s :session-id))
             (proj (plist-get s :project-dir))
             (proj-display (replace-regexp-in-string "^-+" "" proj))
             (desc (or (plist-get s :description) ""))
             (buf  (gethash sid live-bufs))
             (tag  (if buf "LIVE" "SAVED"))
             (label (format "[%s] %s" tag proj-display)))
        (unless (member sid running-ids)
          (let ((unique-label (if (gethash label meta)
                                  (format "%s  [%s]" label (substring sid 0 6))
                                label)))
            (puthash unique-label (list :kind (if buf 'live 'saved) :session-id sid
                                        :project-dir proj :description desc)
                     meta)
            (push unique-label candidates)))))
    (when (null candidates)
      (user-error "No Claude Code sessions found"))
    (let* ((completion-extra-properties
            (list :annotation-function
                  (lambda (cand)
                    (when-let ((desc (plist-get (gethash cand meta) :description)))
                      (propertize (concat "  " desc) 'face 'completions-annotations)))))
           (choice (completing-read "Open Claude session: "
                                    (nreverse candidates) nil t))
           (info (gethash choice meta)))
      (pcase (plist-get info :kind)
        ('live  (switch-to-buffer (plist-get info :buffer)))
        ('run   (let ((default-directory (or (plist-get info :cwd) default-directory)))
                  (agent-shell-resume-session (plist-get info :session-id))))
        ('saved (agent-shell-resume-session (plist-get info :session-id)))))))

(global-set-key (kbd "C-x a") #'my/claude-open-agent)

(load (expand-file-name "claude-panel.el" user-emacs-directory))
(declare-function claude-panel-toggle "claude-panel")
(global-set-key (kbd "M-9") #'claude-panel-toggle)

(global-set-key (kbd "C-c s") (lambda () (interactive) (dired "~/.snowflake")))

(load (expand-file-name "my-agent-shell.el" user-emacs-directory))


(defun my/adjust-font-by-monitor (&rest _)
  "Adjust default font size for each frame based on its monitor's physical width."
  (interactive)
  (dolist (frame (frame-list))
    (let* ((monitor (frame-monitor-attributes frame))
           (geometry (assoc 'geometry monitor))
           (width (nth 3 geometry))) ;; Gets physical monitor width
      (cond
       ((>= width 3840) (set-face-attribute 'default frame :height 250))
       ((>= width 2560) (set-face-attribute 'default frame :height 180))
       (t               (set-face-attribute 'default frame :height 110))))))

(use-package dispwatch
  :ensure t
  :config
  (dispwatch-mode 1)
  ;; Add the named function to the hook
  (add-hook 'dispwatch-display-change-hooks #'my/adjust-font-by-monitor)
  ;; Run it once immediately to set the font for current frames
  (my/adjust-font-by-monitor))
