(global-set-key [C-wheel-up]  'text-scale-increase)

(global-set-key [C-wheel-down]  'text-scale-decrease)

(global-set-key [C-M-mouse-4]  'text-scale-increase)

(global-set-key [C-M-mouse-5]  'text-scale-decrease)


(global-unset-key (kbd "C-o"))
(use-package expand-region
  :ensure t
  :config
  (global-set-key (kbd "C-o") 'er/expand-region))

(use-package swiper
  :ensure t
  :init
  (progn
    (ivy-mode 1)
    (setq ivy-use-virtual-buffers t)
    (setq enable-recursive-minibuffers t)
    ;; enable this if you want `swiper' to use it
    (setq search-default-mode #'char-fold-to-regexp)
    (global-set-key (kbd "M-s M-s") 'swiper)
    (global-set-key(kbd "M-s M-k") 'counsel-git-grep)))


(global-unset-key (kbd "C-x o"))
(use-package ace-window
  :ensure t
  :init
  (progn
    (global-set-key (kbd "C-x o") 'ace-window)
    (custom-set-faces
     '(aw-leading-char-face
       ((t (:inherit ace-jump-face-foreground :height 3.0)))))
    ))
