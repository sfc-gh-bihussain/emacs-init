;; Loaded before GUI by emacs' runtime

;; Recompile any top-level .el whose .elc is missing or stale, before init loads.
(dolist (src (directory-files user-emacs-directory t "\\.el\\'"))
  (unless (string= (file-name-nondirectory src) "early-init.el")
    (let ((compiled (concat src "c")))
      (when (or (not (file-exists-p compiled))
                (file-newer-than-file-p src compiled))
        (byte-compile-file src)))))

(add-hook 'emacs-startup-hook
	  (lambda () (when (get-buffer "*scratch*")
		       (kill-buffer "*scratch*")
		       (when (get-buffer "*Messages*")
			 (kill-buffer "*Messages*")))))
