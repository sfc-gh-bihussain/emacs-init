
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
