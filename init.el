;;;;;;;;;;;;;;;;;;;;;;
;;Init.el specific notes
;;;;;;;;;;;;;;;;;;;;;;
;; https://www.reddit.com/r/emacs/comments/3kqt6e/2_easy_little_known_steps_to_speed_up_emacs_start/
(defvar gc-cons-threshold--orig gc-cons-threshold)
(setq gc-cons-threshold (* 100 1024 1024)
      gc-cons-percentage 0.6
      file-name-handler-alist nil)

(defun rag-set-gc-threshold ()
  "Reset `gc-cons-threshold' and `gc-cons-percentage' to their default values."
  (setq gc-cons-threshold gc-cons-threshold--orig
        gc-cons-percentage 0.1
        file-name-handler-alist rag--file-name-handler-alist))

(setenv "PATH" (concat "C:\\msys64\\mingw64\\bin;" (getenv "PATH")))
;;;;;;;;;;;;;;;;;;;;;;
;;Package management
;;;;;;;;;;;;;;;;;;;;;;
(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/"))
(package-initialize)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
;;try <package name> uses package for current emacs session
(use-package try
  :ensure t)
;;;;;;;;;;;;;;;;;;;;;;
;;Interface
;;;;;;;;;;;;;;;;;;;;;;
(setq inhibit-startup-message t)
;;Windows mouse wheel 
(global-set-key [C-wheel-up]  'text-scale-increase)
(global-set-key [C-wheel-down]  'text-scale-decrease)
;;Putty sends mouse-4 and mouse-5 for wheel
(global-set-key [C-M-mouse-4]  'text-scale-increase)
(global-set-key [C-M-mouse-5]  'text-scale-decrease)

;; Not needed for terminal emacs

(tool-bar-mode -1)
(menu-bar-mode 1)
(toggle-scroll-bar 1)

(use-package color-theme-modern
  :ensure t)
(load-theme 'charcoal-black t)
(use-package beacon
  :ensure t
  :config
  (beacon-mode 1)
  (setq beacon-color "#666666"))

(use-package indent-guide
  :ensure t
  :config
  (indent-guide-global-mode))

(setq c-basic-offset 2)

;;;;;;;;;;;;;;;;;;;;;;
;;Interaction
;;;;;;;;;;;;;;;;;;;;;;

;;Open shell current buffer
(push (cons "\\*shell\\*" display-buffer--same-window-action) display-buffer-alist)

;;C-x r j $reg to jump
(set-register ?i '(file . "~/.emacs.d/init.el"))
(set-register ?d '(file . "C:/Users/User/Documents"))
(set-register ?m '(file . "C:/MinGW/bin"))
(set-register ?4 '(file . "C:/Users/User/Documents/Assignments/CS240"))

;;C-c <Left> C-c <Right>
(winner-mode t)

(load-library "hideshow")
(add-hook 'prog-mode-hook (lambda() (hs-minor-mode 1)))
(global-unset-key (kbd "C-M-h"))
(global-unset-key (kbd "C-M-s"))
(global-set-key (kbd "C-M-h") 'hs-hide-block)
(global-set-key (kbd "C-M-s") 'hs-show-block)
(global-set-key (kbd "C-M-:") 'hs-show-all)
(global-set-key (kbd "C-M-;") 'hs-hide-all)



;;C-x <delay> brings up help window
(use-package which-key
  :ensure t
  :config (which-key-mode))

;;Flexible pattern matching (e.g. C-x C-f gives list of completions)
(setq indo-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode 1)

;;C-x C-b brings up different looking search
(defalias 'list-buffers 'ibuffer)
;;(defalias 'list-buffers 'ibuffer-other-window)

;;Seems broken on putty
(use-package tabbar
  :ensure t
  :config
  (tabbar-mode 1))

;; C-x o gives instant jumps
(global-unset-key (kbd "C-x o"))
(use-package ace-window
  :ensure t
  :init
  (progn
    (global-set-key (kbd "C-x o") 'ace-window)
    (custom-set-faces
     '(aw-leading-char-face
       ((t (:inherit ace-jump-face-foreground :height 3.0)))))
    ))
(global-set-key (kbd "C-M-n") 'other-window)

(use-package counsel
  :ensure t)

;;Better searching
(use-package swiper
  :ensure t
  :init
  (progn
    (ivy-mode 1)
    (setq ivy-use-virtual-buffers t)
    (setq enable-recursive-minibuffers t)
    ;; enable this if you want `swiper' to use it
    ;; (setq search-default-mode #'char-fold-to-regexp)
    (global-set-key (kbd "M-s M-s") 'swiper)
    (global-set-key (kbd "M-x") 'counsel-M-x)
    (global-set-key (kbd "C-x C-f") 'counsel-find-file)
    (global-set-key (kbd "C-c g") 'counsel-git)
    (global-set-key (kbd "C-c j") 'counsel-git-grep)
    (global-set-key (kbd "C-x l") 'counsel-locate)
    (define-key minibuffer-local-map (kbd "C-r") 'counsel-minibuffer-history)
    ))

(use-package undo-tree
  :ensure t
  :init
  (global-undo-tree-mode))

;;Indent stuff as you are typing
(use-package aggressive-indent
  :ensure t
  :config
  (global-aggressive-indent-mode 1))

(global-unset-key (kbd "C-o"))
(use-package expand-region
  :ensure t
  :config
  (global-set-key (kbd "C-o") 'er/expand-region))

;;;;;;;;;;;;;;;;;;;;;;
;;Autocompletion
;;;;;;;;;;;;;;;;;;;;;;
(use-package auto-complete
  :ensure t
  :init
  (progn
    (ac-config-default)
    (global-auto-complete-mode t)))

(use-package flycheck
  :ensure t
  :init
  (global-flycheck-mode t))

(use-package yasnippet
  :ensure t
  :init
  (yas-global-mode 1))
(use-package yasnippet-snippets
  :ensure t)

(setq yas-prompt-functions '(yas-x-prompt yas-dropdown-prompt))

;;C++ completion
;;I have not gotten this to work :/
(use-package ggtags
  :ensure t
  :config
  (add-hook 'c-mode-common-hook
	    (lambda ()
	      (when (derived-mode-p 'c-mode 'c++-mode 'java-mode)
		(ggtags-mode 1)))))

(use-package company
  :ensure t
  :config
  (setq company-idle-delay 2)
  (setq company-minimum-prefix-length 3)
  (add-hook 'after-init-hook 'global-company-mode))

(use-package company-irony
  :ensure t
  :config
  (require 'company)
  (add-to-list 'company-backends 'company-irony))

;; (use-package irony
;;   :ensure t
;;   :config
;;   (add-hook 'c++-mode-hook 'irony-mode)
;;   (add-hook 'c-mode-hook 'irony-mode)
;;   (add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options))

;; (add-to-list 'package--builtin-versions '(emacs 25))

;; (use-package lsp-mode
;;   :ensure t)

;; (use-package cquery
;;   :ensure t)

(use-package tex
  :ensure auctex)

(use-package rtags
  :commands rtags-mode
  :bind (("C-. r D" . rtags-dependency-tree)
	 ("C-. r F" . rtags-fixit)
	 ("C-. r R" . rtags-rename-symbol)
	 ("C-. r T" . rtags-tagslist)
	 ("C-. r d" . rtags-create-doxygen-comment)
	 ("C-. r c" . rtags-display-summary)
	 ("C-. r e" . rtags-print-enum-value-at-point)
	 ("C-. r f" . rtags-find-file)
	 ("C-. r i" . rtags-include-file)
	 ("C-. r i" . rtags-symbol-info)
	 ("C-. r m" . rtags-imenu)
	 ("C-. r n" . rtags-next-match)
	 ("C-. r p" . rtags-previous-match)
	 ("C-. r r" . rtags-find-references)
	 ("C-. r s" . rtags-find-symbol)
	 ("C-. r v" . rtags-find-virtuals-at-point))
  :bind (:map c-mode-base-map
	      ("M-." . rtags-find-symbol-at-point)))
(add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)

;;Commands for debugging missing colors in xterm
;;(assoc 'tty-type (frame-parameters (car (frame-list))))
;;(list-colors-display)
;; Try setting this in .bashrc to allow emacs themes:
;;TERM=xterm-256color

(defun yes-or-no-p->-y-or-n-p (orig-fun &rest r)
  (cl-letf (((symbol-function 'yes-or-no-p) #'y-or-n-p))
    (apply orig-fun r)))

(advice-add 'kill-buffer :around #'yes-or-no-p->-y-or-n-p)

;;Misc
(setq
 backup-by-copying t      ; don't clobber symlinks
 backup-directory-alist
 '(("." . "~/.saves/"))    ; don't litter my fs tree
 delete-old-versions t
 kept-new-versions 6
 kept-old-versions 2)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (company company-irony ggtags aggressive-indent hungry-delete auctex yasnippet-snippets yasnippet flycheck auto-complete expand-region undo-tree swiper ace-window tabbar which-key indent-guide beacon color-theme-modern try use-package))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(aw-leading-char-face ((t (:inherit ace-jump-face-foreground :height 3.0)))))
(put 'erase-buffer 'disabled nil)


(setq-default flycheck-disabled-checkers '(emacs-lisp-checkdoc))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; M-x package-install RET auctex RET
(add-hook 'LaTeX-mode-hook 'TeX-PDF-mode)
;; (add-hook 'LaTeX-mode-hook 'TeX-source-correlate-mode)
;; (setq TeX-source-correlate-method 'synctex)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package pdf-tools
  :ensure t
  :config
  (pdf-tools-install))
(server-start)
(setq TeX-view-program-selection '((output-pdf "PDF Tools"))
      TeX-view-program-list '(("PDF Tools" TeX-pdf-tools-sync-view))
      TeX-source-correlate-start-server t)
;; to have the buffer refresh after compilation
(add-hook 'TeX-after-compilation-finished-functions
	  'TeX-revert-document-buffer)
(add-hook 'doc-view-mode-hook 'auto-revert-mode)


;;Print init time
(emacs-init-time)
