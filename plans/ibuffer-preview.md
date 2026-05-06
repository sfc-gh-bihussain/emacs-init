# Ibuffer with preview mode

## Goal
Replace/improve the current ibuffer config with VC grouping and a buffer preview that lets the user see content while navigating the ibuffer list. The user's stated preference is a low-opacity floating preview frame.

## Files
- `~/.emacs.d/init.el` (or a new `~/.emacs.d/my-ibuffer.el` if it grows)
- `~/.emacs.d/custom.el` if adding `ibuffer-vc` to `package-selected-packages`

## Approach (try-it-out, multiple options to compare)

### Option A — Baseline upgrade (minimal)
```elisp
(use-package ibuffer-vc :ensure t)
(setq ibuffer-show-empty-filter-groups nil)
(add-hook 'ibuffer-hook
          (lambda ()
            (ibuffer-vc-set-filter-groups-by-vc-root)
            (unless (eq ibuffer-sorting-mode 'alphabetic)
              (ibuffer-do-sort-by-alphabetic))))
(setq ibuffer-formats
      '((mark modified read-only vc-status-mini " "
              (name 30 30 :left :elide) " "
              (size 9 -1 :right) " "
              (mode 16 16 :left :elide) " "
              filename-and-process)))
(global-set-key (kbd "C-x C-b") 'ibuffer)
```

### Option B — Inline preview in side window
```elisp
(defun my/ibuffer-preview-current ()
  "Show buffer at point in a side window."
  (when (derived-mode-p 'ibuffer-mode)
    (let ((buf (ibuffer-current-buffer t)))
      (when (buffer-live-p buf)
        (display-buffer buf
                        '((display-buffer-in-side-window)
                          (side . right)
                          (window-width . 0.6)))))))

(add-hook 'ibuffer-mode-hook
          (lambda () (add-hook 'post-command-hook
                                #'my/ibuffer-preview-current nil t)))
```

### Option C — Floating low-opacity child frame (user preference)
```elisp
(defvar my/ibuffer-preview-frame nil)

(defun my/ibuffer-preview-frame-show (buf)
  (let ((params `((parent-frame . ,(selected-frame))
                  (no-accept-focus . t)
                  (minibuffer . nil)
                  (undecorated . t)
                  (alpha . 80)
                  (left . 0.5)
                  (top . 0.5)
                  (width . 80)
                  (height . 25))))
    (unless (frame-live-p my/ibuffer-preview-frame)
      (setq my/ibuffer-preview-frame (make-frame params)))
    (with-selected-frame my/ibuffer-preview-frame
      (switch-to-buffer buf))))

(defun my/ibuffer-preview ()
  (when (derived-mode-p 'ibuffer-mode)
    (when-let ((buf (ibuffer-current-buffer t)))
      (when (buffer-live-p buf)
        (my/ibuffer-preview-frame-show buf)))))

(defun my/ibuffer-preview-hide ()
  (when (and my/ibuffer-preview-frame
             (frame-live-p my/ibuffer-preview-frame))
    (delete-frame my/ibuffer-preview-frame)
    (setq my/ibuffer-preview-frame nil)))

(add-hook 'ibuffer-mode-hook
          (lambda () (add-hook 'post-command-hook #'my/ibuffer-preview nil t)))
(add-hook 'ibuffer-mode-hook
          (lambda () (add-hook 'kill-buffer-hook #'my/ibuffer-preview-hide nil t)))
```

`alpha` works on macOS / X11. On macOS Emacs 29+, `alpha-background` is more correct (only background is transparent, text stays opaque).

## Decision
Implement A first (everyone wants the baseline). Then layer in C as a defcustom-toggleable feature. Skip B unless C is too flaky.

## Verification
- `C-x C-b` opens grouped by VC root.
- Cursor movement through the list shows a low-opacity floating preview.
- Quitting ibuffer (`q`) closes the preview frame.
