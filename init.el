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

(setq custom-file (concat user-emacs-directory "custom.el"))

(if (eq system-type 'windows-nt)
    (setq shell-file-name "C:/cygwin64/bin/bash.exe"))

(when (file-exists-p custom-file)
  (load custom-file))

(setq mac-command-modifier 'meta)

(setq initial-scratch-message nil)

(setq-default message-log-max nil)

(if (get-buffer "*Messages*")
    (kill-buffer "*Messages*"))

(tooltip-mode 0) ; Mouse over tooltip


					;(setq global-auto-revert-non-file-buffers t)
(global-auto-revert-mode)

(add-hook 'dired-mode-hook 'auto-revert-mode)

(winner-mode 1)
(setq use-short-answers t)

(setq inhibit-startup-message t)
(setq backup-directory-alist (quote ((".*" . "~/.emacs_backups/"))))


(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents (package-refresh-contents))
(unless (package-installed-p 'use-package) (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)


(global-set-key (kbd "C-h C-e") 'package-list-packages)

(global-unset-key (kbd "C-x k"))
(defun volatile-kill-buffer ()
  "Kill current buffer unconditionally."
  (interactive)
  (let ((buffer-modified-p nil))
    (kill-buffer (current-buffer))))

;; Unconditionally kill unmodified buffers.
(global-set-key (kbd "C-x k") 'volatile-kill-buffer)


(defun my-open-init-file ()
  "Open the user's Emacs initialization file."
  (interactive)
  (find-file user-init-file))
(defun my-open-zshrc ()
  "Opens the current user's .zshrc file."
  (interactive)
  (find-file "~/.zshrc"))

(global-set-key (kbd "C-c i") 'my-open-init-file)
(global-set-key (kbd "C-c z") 'my-open-zshrc)

(use-package try
  :ensure t)

(use-package
  command-log-mode
  :diminish
  :config
  (command-log-mode 1))

(use-package
  try)

;; Tried to make hotkey for case insensitive toggle, failed
;; (defun my/toggle-ivy-case-fold-search ()
;;   "Toggle case sensitivity for Ivy/Swiper search."
;;   (interactive)
;;   (setq ivy-case-fold-search-default (not ivy-case-fold-search-default))
;;   (message "Ivy case-fold-search is now: %s" (if ivy-case-fold-search-default "ON" "OFF")))

(use-package swiper
  :bind
  (("C-s" . swiper)
   ("M-s M-s" . swiper-all)))

(use-package counsel)
(use-package ivy
  :diminish
  :bind (
	 ("C-c v" . ivy-push-view)
	 ("C-c C-v" . ivy-pop-view)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
	 ;; meh , i just use C-n an C-p
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1)
  (setq ivy-count-format "(%d/%d) ")
  ;; Idk what this does lol just recommended by oremacs.com/swiper
  (setq ivy-use-virtual-buffers t))
(global-set-key "\C-x\C-b" 'ibuffer)
(use-package ivy-rich
  :init
  (ivy-rich-mode 1))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package which-key
  :init
  (which-key-mode)
  (setq which-key-idle-delay 0.5)
  (setq which-key-idle-secondary-delay 0.05)
  :diminish which-key-mode
  :config
  )


(use-package lsp-java
  :config
  (lsp-mode t))

(add-hook 'python-mode-hook 'lsp-deferred)

(use-package yaml-mode
  :ensure t)


(use-package treemacs
  :ensure t
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
  :ensure t
  :config
  (add-hook 'sql-mode-hook 'blamer-mode)
  (add-hook 'prog-mode-hook 'blamer-mode))

(defun my-treemacs-projectile-hook ()
  "Opens Treemacs with the current Projectile project as its root."
  (when (projectile-project-p)  ;; Ensure we are in a Projectile project
    (treemacs-add-and-display-current-project-exclusively)))


;; (use-package treemacs-projectile
;;   :config
;;   (add-hook 'projectile-after-switch-project-hook 'my-treemacs-projectile-hook))


;; (use-package elpy
;;   :ensure t
;;   :init
;;   (elpy-enable)
;;   (setq elpy-rpc-virtualenv-path 'current))

(use-package ruff-format
  :config
  (add-hook 'python-mode-hook 'ruff-format-on-save-mode))

(use-package pyvenv
  :ensure t
  :config
  (pyvenv-mode 1))

(use-package direnv
  :ensure t
  :config
  (direnv-mode 1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; STUFF POSSIBLY TO REMOVE
;; These are the defaults in 29 for me, idk why ppl set these lol
(column-number-mode 0) ; Numbers on bottom
(show-paren-mode 1)

;; Apparently IDO is old so it might be shit
;; Apparently IVY/HELM are the two most important ones
;; You can install both and use them in differenet contexts :o
;; Autocompletion
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(setq ido-file-extensions-order '(".txt" ".py" ".el" ".java"))
(ido-mode 0)
(put 'erase-buffer 'disabled nil)

(use-package csv-mode)

(use-package dotenv-mode
  :config
  (add-to-list 'auto-mode-alist '("\\.env\\'" . dotenv-mode))
  )

(defun xah-open-in-vscode ()
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

(use-package posframe
  :ensure t
  :config
  (defun my/notify--hide ()
    (posframe-hide " *my-notify*")
    (remove-hook 'post-command-hook #'my/notify--hide))

  (defun my/notify (msg)
    "Show MSG in a centered posframe popup; dismisses on next input or after 2s."
    (posframe-show " *my-notify*"
                   :string (concat "\n  " msg "  \n")
                   :poshandler #'posframe-poshandler-frame-center
                   :timeout 2
                   :border-width 2
                   :border-color (face-attribute 'default :foreground)
                   :internal-border-width 8)
    (run-with-timer 0 nil (lambda ()
                            (add-hook 'post-command-hook #'my/notify--hide)))))

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

(use-package vterm
  :ensure t
  :config
  ;; Set vterm text buffering delay
  (setq vterm-timer-delay 0.01)
  :bind (:map vterm-mode-map
	      ("M-0" . nil)
	      ("M-p" . nil)
	      ("M-'" . nil)
	      ))

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
(defun revert-buffer-no-confirm ()
  "Revert buffer without confirmation."
  (interactive)
  (revert-buffer t t))


(defun my/vterm-update-buffer-and-directory (orig-func title)
  "Update vterm buffer name and `default-directory` from shell info.
Title format: 'name|/path/to/dir' where name is repo/branch, cortex[conn] repo/branch, or dirname."
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

(use-package ace-window
  :ensure t
  :init
  (global-set-key (kbd "M-o") 'ace-window )
  :config
  (setq aw-dispatch-always t)
  (setq aw-keys '(?p ?w ?o ?q ?e))
  :custom-face
  (aw-leading-char-face ((t (:foreground "OrangeRed" :weight bold :height 5.0))))
  (aw-background-face   ((t (:foreground "gray50"))))
  (aw-mode-line-face    ((t (:foreground "DeepSkyBlue" :weight bold)))))

(setq select-enable-clipboard t)

(global-set-key (kbd "M-g M-g") 'revert-buffer-no-confirm)

(setq auto-save-file-name-transforms '((".*" "~/.emacs.d/autosaves/\\1" t)))

;; Create the autosave directory if it doesn't exist
(unless (file-exists-p "~/.emacs.d/autosaves/")
  (make-directory "~/.emacs.d/autosaves/"))

(use-package dashboard
  :ensure t
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
;; Format: "(icon title help action face prefix suffix)"
;; (dashboard-navigator-buttons
;;       `(;; line1
;;         ((,(nerd-icons-octicon "mark-github" :height 1.1 :v-adjust 0.0)
;;           "Homepage"
;;           "Browse homepage"
;;           (lambda (&rest _) (browse-url "homepage")))
;;          ("★" "Star" "Show stars" (lambda (&rest _) (show-stars)) warning)
;;          ("?" "" "?/h" #'show-help nil "<" ">"))
;;         ;; line 2
;;         ((,(all-the-icons-faicon "linkedin" :height 1.1 :v-adjust 0.0)
;;           "Linkedin"
;;           ""
;;           (lambda (&rest _) (browse-url "homepage")))
;;          ("⚑" nil "Show flags" (lambda (&rest _) (message "flag")) error))))



(use-package projectile
  :diminish
  :ensure t
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
  (projectile-discover-projects-in-directory "~/code/coco_crossing")
  )
;; hack
;;(projectile-discover-projects-in-directory "~/code/")

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
  :custom
  (vertico-count 13)                    ; Number of candidates to display
  (vertico-resize t)
  (vertico-cycle nil) ; Go from last to first candidate and first to last (cycle)?
  :general
  (:keymaps 'vertico-map
            "<tab>" #'vertico-insert  ; Insert selected candidate into text area
            "<escape>" #'minibuffer-keyboard-quit ; Close minibuffer
            ;; NOTE 2022-02-05: Cycle through candidate groups
            "C-M-n" #'vertico-next-group
            "C-M-p" #'vertico-previous-group)
  :config
  (vertico-mode))


(use-package magit)

;; Allow gpg signing in emacs
(use-package pinentry :ensure t)
(pinentry-start)

(use-package why-this
  :config
  :diminish
  (global-why-this-mode t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; UI stuff:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Side bars
(set-fringe-mode 0) 
(scroll-bar-mode 0)

(tool-bar-mode 0)
(menu-bar-mode 0)
;; Ugly way to hide top bar. TODO Is there a "mode?"
(setq default-frame-alist
      (append
       '((undecorated-round . t))
       default-frame-alist))
(global-display-line-numbers-mode 0)
;; todo: make thin bar on RHS of numbers, rounded, only 95% of the bar
(set-face-attribute 'line-number nil
		    :background nil
		    :box nil
		    :height 120)

(setq display-line-numbers-type 'relative)
(add-hook 'prog-mode-hook 'display-line-numbers-mode)

(setq visible-bell t)
(if (find-font (font-spec :family "Cascadia Code"))
    (set-face-attribute 'default nil :font "Consolas 18"))

(use-package beacon
  :config
  (beacon-mode 1))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Theme stuff:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Meh
;; (load-theme 'tango-dark)
;; modus theme meh

(use-package nerd-icons
  :ensure t)
;; TODO BH
;; (if (not (find-font (font-spec :name "NFM")))
;;     (nerd-icons-install-fonts))
(use-package doom-themes
  :ensure t
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
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
(global-unset-key (kbd "M-t"))
(use-package theme-looper
  :config
  :bind
  ("M-t M-t" . theme-looper-enable-random-theme))

(add-hook 'emacs-startup-hook 'theme-looper-enable-random-theme)
;;(load-theme 'automata t)
;; Just to use consult theme to page thru themes while seeing them
(use-package consult)

;; (use-package doom-modeline
;;   :ensure t
;;   :init (doom-modeline-mode 1) 
;;   :custom ((doom-modeline-height 15)))

(use-package spaceline
  :config (spaceline-emacs-theme))

;;; testing rounded fringes
(put 'downcase-region 'disabled nil)

(use-package default-text-scale
  :config (default-text-scale-mode))


(defun dump-vterm-to-scratch ()
  "Copy vterm buffer to *scratch* without trailing empty lines, keeping colors."
  (interactive)
  (unless (derived-mode-p 'vterm-mode)
    (user-error "This command only works in vterm buffers"))
  
  (let* ((vterm-buffer (current-buffer))
         (scratch-buf (get-buffer-create "*scratch*"))
         ;; 1. Get the content as a string WITH text properties (colors)
         (content (buffer-substring (point-min) (point-max))))
    
    (with-current-buffer scratch-buf
      (goto-char (point-max))
      ;; 2. Insert content
      (let ((start (point)))
        (insert content)
        ;; 3. Strip the extra terminal 'empty' padding lines at the end
        (save-excursion
          (goto-char (point-max))
          (delete-blank-lines)))
      
      ;; 4. Move view to the bottom
      (goto-char (point-max)))
    
    ;; 5. Switch focus to scratch
    (switch-to-buffer scratch-buf)
    (message "Vterm dumped and cleaned!")))

(global-set-key (kbd "M-'") 'dump-vterm-to-scratch)
(use-package expand-region
  :config
  (global-set-key (kbd "M-[") 'er/expand-region))
