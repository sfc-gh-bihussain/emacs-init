# Fix `desktop-save-mode`

## Goal
`desktop-save-mode` is meant to save and restore window layout, open buffers, and frame state across Emacs restarts. The user reports it doesn't work. `~/.emacs.d/.emacs.desktop` and `.emacs.desktop.lock` are already present.

## File
- `~/.emacs.d/init.el` (grep for `desktop-`)

## Investigation
```sh
emacsclient --eval '(list desktop-save-mode desktop-dirname desktop-base-file-name (file-exists-p (desktop-full-file-name)))'
emacsclient --eval '(with-current-buffer "*Messages*" (buffer-substring-no-properties (max (point-min) (- (point-max) 4000)) (point-max)))'
```

Likely causes (in order of frequency):
1. `(desktop-save-mode 1)` is not being called at startup.
2. `.emacs.desktop.lock` from a prior session is preventing load (`desktop-load-locked-desktop` defaults to `'ask` and the prompt may be missed).
3. `desktop-dirname` is a directory the user no longer expects.

## Fix
In init.el (early, before package loads finish):
```elisp
(setq desktop-load-locked-desktop t      ; load even if .lock present
      desktop-save t                     ; always save without asking
      desktop-restore-eager 5            ; render first 5 buffers eagerly
      desktop-dirname user-emacs-directory)
(desktop-save-mode 1)
```

Test by restarting Emacs and running `M-x desktop-read` if it didn't auto-restore.

## Verification
1. Open several files, layout windows.
2. Restart Emacs.
3. Same windows and buffers come back.
