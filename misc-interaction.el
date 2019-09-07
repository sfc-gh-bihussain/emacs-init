;; Not needed for terminal emacs
(tool-bar-mode -1)
(menu-bar-mode 1)
(toggle-scroll-bar -1)



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

(defalias 'list-buffers 'ibuffer)
