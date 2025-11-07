;; Refresher:
;; C-x C-e execute lisp
;; M-j execute and print on next line
;; M-: eval lisp in minibuffer
;; descibe function C-h f
;; descibe variable C-h v
;; describe package C-h p
;; C-x C--/+ to resize font

;; Possibly need to set the variables for a major mode before enabling the mode


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


(use-package
  command-log-mode
  :diminish
  :config
  (command-log-mode 1))

(use-package
  try)
(use-package swiper
  :bind
  (("C-s" . swiper)))

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

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1) 
  :custom ((doom-modeline-height 15)))

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

(use-package yaml-mode
  :ensure t)
;;(setq treemacs-is-never-other-window t)

(use-package treemacs
  :ensure t
  :config
  (treemacs-follow-mode nil)
  (treemacs-project-follow-mode)
  (treemacs-display-current-project-exclusively)
  :bind
  (("M-0"       . treemacs-select-window)
   ("C-x t 1"   . treemacs-delete-other-windows)
   ("C-x t t"   . treemacs))
  ; IDK Why this was here in my prev config 
  ;(:map treemacs-mode-map ("C-p" . treemacs-previous-line))
  )
(setq doom-themes-treemacs-enable-variable-pitch nil)
(set-face-attribute 'treemacs-file-face nil :family "JetBrains Mono" :height 120)

(defun my-treemacs-projectile-hook ()
  "Opens Treemacs with the current Projectile project as its root."
  (when (projectile-project-p)  ;; Ensure we are in a Projectile project
    (treemacs-add-and-display-current-project-exclusively)))

(add-hook 'projectile-after-switch-project-hook 'my-treemacs-projectile-hook)
(use-package treemacs-projectile)


(use-package elpy
  :ensure t
  :init
  (elpy-enable))


(load-file "~/.emacs.d/theme.el")
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

(defun my/copy-buffer-file-name-to-clipboard ()
  "Copy the current buffer's file name (full path) to the clipboard."
  (interactive)
  (let ((filename (buffer-file-name)))
    (when filename
      (kill-new filename)
      (message "Copied buffer file name '%s' to the clipboard." filename))))
(global-set-key (kbd "C-c p") 'my/copy-buffer-file-name-to-clipboard)

(use-package vterm
  :ensure t
  :config
  (setq vterm-timer-delay 0.01))

(use-package ace-window
  :ensure t
  :init
  (global-set-key (kbd "M-o") 'ace-window )
  :config
  (setq aw-dispatch-always t)
  (setq aw-keys '(?p ?[ ?] ?\; ?')))
(setq select-enable-clipboard t)


(defun vterm-at-current-location ()
  "Open a new vterm buffer in the current buffer's directory."
  (interactive)
  (let ((default-directory (file-truename default-directory)))
    (vterm)
    (rename-uniquely)
    ;(rename-buffer (format "*vterm: %s*" (file-name-nondirectory default-directory)))
    ))
(global-set-key (kbd "C-c t") 'vterm-at-current-location)
(defun revert-buffer-no-confirm ()
  "Revert buffer without confirmation."
  (interactive)
  (revert-buffer t t))
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
                     ;;(bookmarks . 5)
                     (projects . 5))) ; Display 5 recent projects
  (dashboard-projects-backend 'projectile) ; Use Projectile for project lists
  (dashboard-banner-logo-title nil)
  (dashboard-startup-banner '("~/gifs/raiden_lets_dance_no_loop.gif")) ; Or nil for a list, or 'official for the Emacs logo
  (dashboard-center-content t)
  ;; vertically center content
  (dashboard-vertically-center-content t)
  (dashboard-icon-type 'nerd-icons)
  ;; Format: "(icon title help action face prefix suffix)"
(dashboard-navigator-buttons
      `(;; line1
        ((,(nerd-icons-octicon "mark-github" :height 1.1 :v-adjust 0.0)
          "Homepage"
          "Browse homepage"
          (lambda (&rest _) (browse-url "homepage")))
         ("★" "Star" "Show stars" (lambda (&rest _) (show-stars)) warning)
         ("?" "" "?/h" #'show-help nil "<" ">"))
        ;; line 2
        ((,(all-the-icons-faicon "linkedin" :height 1.1 :v-adjust 0.0)
          "Linkedin"
          ""
          (lambda (&rest _) (browse-url "homepage")))
         ("⚑" nil "Show flags" (lambda (&rest _) (message "flag")) error))))
  (dashboard-startupify-list '(dashboard-insert-banner
                                  dashboard-insert-newline
                                  dashboard-insert-banner-title
                                  dashboard-insert-newline
                                  dashboard-insert-navigator
                                  dashboard-insert-newline
                                  dashboard-insert-init-info
                                  dashboard-insert-items
                                  dashboard-insert-newline
                                  dashboard-insert-footer))
  )

(use-package projectile
  :ensure t
  :init
  (setq projectile-project-search-path
   '(("~/code/" . 1) "~/.emacs.d/" ))
  :config
  (global-set-key (kbd "M-p") 'projectile-command-map)
  (projectile-mode +1)
  )
;; hack
(projectile-discover-projects-in-directory "~/code/")

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
(line-number-mode 0)
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
  (load-theme 'doom-one t)
    ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)

  (setq doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
   (doom-themes-treemacs-config)
   ;; Corrects (and improves) org-mode's native fontification.
   ;; lol i dont use org tho
  (doom-themes-org-config))
