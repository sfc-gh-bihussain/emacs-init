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
