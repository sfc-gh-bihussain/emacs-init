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
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.5)
  (setq which-key-idle-secondary-delay 0.05))


(use-package lsp-java
  :config
  (lsp-mode t))

(use-package yaml-mode
  :ensure t)
(use-package treemacs
  :ensure t
  :config
  (treemacs-follow-mode t)
  :bind
  (("M-0"       . treemacs-select-window)
   ("C-x t 1"   . treemacs-delete-other-windows)
   ("C-x t t"   . treemacs))
  ; IDK Why this was here in my prev config 
  ;(:map treemacs-mode-map ("C-p" . treemacs-previous-line))
  )

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
