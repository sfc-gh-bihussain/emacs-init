;;TODO: GTAGS, Flycheck, Yasnippet, Company, Irony, Ivy


(use-package add-node-modules-path
  :ensure t
  :config
  (add-hook 'web-mode-hook #'add-node-modules-path)
  (add-hook 'web-mode-hook #'prettier-js-mode))

(use-package prettier-js
  :ensure t
  :config
  (add-hook 'js2-mode-hook 'prettier-js-mode)
  (add-hook 'web-mode-hook 'prettier-js-mode))
