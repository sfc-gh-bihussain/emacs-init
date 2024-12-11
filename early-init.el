(add-hook 'emacs-startup-hook
	  (lambda () (when (get-buffer "*scratch*")
		       (kill-buffer "*scratch*")
		       (when (get-buffer "*Messages*")
			 (kill-buffer "*Messages*")))))
