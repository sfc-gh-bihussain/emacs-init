(add-hook 'text-mode-hook 'linum-mode)
(add-hook 'prog-mode-hook 'linum-mode)

(tool-bar-mode -1)

(menu-bar-mode 1)

(toggle-scroll-bar -1)

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
  (indent-guide-global-mode)
  (setq indent-guide-delay 0)
  "TODO: See if performance degrades with recursive guide"
  (setq indent-guide-recursive t))

;;C-c <Left> C-c <Right>
(winner-mode t)

(use-package golden-ratio
  :ensure t
  :config
  (golden-ratio-mode 1))


(use-package dimmer
  :ensure t
  :config
  (dimmer-mode 1))

(use-package rainbow-delimiters
  :ensure t
  :config
  (rainbow-delimiters-mode 1)
  )
(setq rainbow-delimiters-depth-1-face "red")

;; (use-package dired-sidebar
;;   :bind (("C-x C-n" . dired-sidebar-toggle-sidebar))
;;   :ensure t
;;   :commands (dired-sidebar-toggle-sidebar)
;;   :config
;;   (setq dired-sidebar-subtree-line-prefix "__")
;;   (setq dired-sidebar-theme 'vscode)
;;   (setq dired-sidebar-use-term-integration t)
;;   (setq dired-sidebar-use-custom-font t))

