;;;;;;;;;;;;;;;;;;;;;;
;;Interface
;;;;;;;;;;;;;;;;;;;;;;
(setq inhibit-startup-message t)
;;Doesnt work with putty. Go to properties->window->change manually
(global-set-key [C-mouse-wheel-up-event]  'text-scale-increase)
;; Not needed for terminal emacs
(tool-bar-mode 0)
(put 'erase-buffer 'disabled nil)

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
;;Interaction
;;;;;;;;;;;;;;;;;;;;;;
;;C-x <delay> brings up help window
(use-package which-key
  :ensure t
  :config (which-key-mode))

;;Flexible pattern matching (e.g. C-x C-f gives list of completions)
(setq indo-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode 1)

;;C-x C-b brings up different looking search
;;(defalias 'list-buffers 'ibuffer)
(defalias 'list-buffers 'ibuffer-other-window)

;Seems broken on putty
(use-package tabbar
  :ensure t
  :config
  (tabbar-mode 1))

;; C-x o gives instant jumps
(use-package ace-window
  :ensure t
  :init
  (progn
   (global-set-key [remap other-window] 'ace-window)
     (custom-set-faces
     '(aw-leading-char-face
       ((t (:inherit ace-jump-face-foreground :height 3.0)))))
    ))

;;Better searching
(use-package swiper
  :ensure t
  :config
  (progn
    (ivy-mode 1)
    (setq ivy-use-virtual-buffers t)
    (setq enable-recursive-minibuffers t)
    ;; enable this if you want `swiper' to use it
    ;; (setq search-default-mode #'char-fold-to-regexp)
    (global-set-key "\C-s" 'swiper)
    (global-set-key (kbd "M-x") 'counsel-M-x)
    (global-set-key (kbd "C-x C-f") 'counsel-find-file)
    (global-set-key (kbd "C-c g") 'counsel-git)
    (global-set-key (kbd "C-c j") 'counsel-git-grep)
    (global-set-key (kbd "C-x l") 'counsel-locate)
    (define-key minibuffer-local-map (kbd "C-r") 'counsel-minibuffer-history)
    ))

(use-package auto-complete
  :ensure t
  :init
  (progn
    (ac-config-default)
    (global-auto-complete-mode t)
    ))


;;Commands for debugging missing colors in xterm
;(assoc 'tty-type (frame-parameters (car (frame-list))))
;(list-colors-display)
;; Try setting this in .bashrc to allow emacs themes:
;;TERM=xterm-256color
