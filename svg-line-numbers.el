;; -*- lexical-binding: t -*-

;; Line numbers with pill-style face highlighting.
;; Uses built-in display-line-numbers-mode (handles wrapping, no overlay bugs).

(eval-when-compile (require 'color))

(defun my/blend-colors (c1 c2 alpha)
  "Blend C1 into C2 by ALPHA (0.0-1.0), returning a hex string."
  (let ((blended (cl-mapcar (lambda (a b) (+ (* alpha a) (* (- 1 alpha) b)))
                            (color-name-to-rgb c1)
                            (color-name-to-rgb c2))))
    (apply #'color-rgb-to-hex (append blended '(2)))))

(setq display-line-numbers-type t)

(defun my/ln--update-faces ()
  "Set line-number faces using current theme colors."
  (let* ((bg       (face-attribute 'default :background nil t))
         (kw       (face-attribute 'font-lock-keyword-face :foreground nil t))
         (fill-dim (my/blend-colors kw bg 0.10))
         (fill-cur (my/blend-colors kw bg 0.28))
         (fg-dim   (my/blend-colors kw bg 0.50))
         (fg-cur   kw))
    (set-face-attribute 'line-number nil
                        :background fill-dim
                        :foreground fg-dim
                        :weight 'normal
                        :box nil)
    (set-face-attribute 'line-number-current-line nil
                        :background fill-cur
                        :foreground fg-cur
                        :weight 'bold
                        :box nil)
    (set-face-attribute 'fringe nil :background fill-dim)))

(add-hook 'prog-mode-hook #'display-line-numbers-mode)

(advice-add 'load-theme :after
            (lambda (&rest _) (my/ln--update-faces)))

(my/ln--update-faces)

(provide 'svg-line-numbers)
