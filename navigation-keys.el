(global-unset-key (kbd "C-x o"))
(global-unset-key (kbd "C-M-n"))
(use-package ace-window
  :ensure t
  :init
  (progn
    (global-set-key (kbd "C-x o") 'ace-window)
    (custom-set-faces
     '(aw-leading-char-face
       ((t (:inherit ace-jump-face-foreground :height 3.0)))))
    ))

(global-set-key (kbd "C-M-n") 'other-window)
