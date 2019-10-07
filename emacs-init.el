;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; https://www.reddit.com/r/emacs/comments/3kqt6e/
(defvar orig-gc-threshold gc-cons-threshold)
(defvar 100-mb (* 100 1024 1024))
(setq gc-cons-threshold 100-mb)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun full-path (@file-relative-path)
  (concat (file-name-directory
	   (or load-file-name buffer-file-name))
	  @file-relative-path))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;(org-babel-load-file (full-path "./myinit.org"))

(let ((file-name-handler-alist nil))
  (load (full-path "./pre-init.el"))
  (load (full-path "./registers.el"))
  (load (full-path "./ui.el"))
  (load (full-path "./global-keys.el"))
  (load (full-path "./startup.el"))
  (load (full-path "./misc-settings.el"))
  (load (full-path "./navigation-keys.el"))
  (load (full-path "./misc-interaction.el"))
  (load (full-path "./auto-complete.el"))
  (load (full-path "./flycheck.el"))
  (load (full-path "./latex.el")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq gc-cons-threshold  orig-gc-threshold)
