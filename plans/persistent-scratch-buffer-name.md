# `persistent-scratch` should save the right scratch buffer

## Goal
The user routinely keeps a buffer literally named `scratch` (no asterisks) and auto-closes the default `*scratch*`. Verify and fix `persistent-scratch-mode` so it saves and restores `scratch`, not `*scratch*`.

## File
- `~/.emacs.d/init.el` (grep for `persistent-scratch`)

## Investigation
```sh
emacsclient --eval '(boundp (quote persistent-scratch-scratch-buffer-p-function))'
emacsclient --eval 'persistent-scratch-scratch-buffer-p-function'
emacsclient --eval '(symbol-function persistent-scratch-scratch-buffer-p-function)'
```

The default `persistent-scratch-default-scratch-buffer-p` matches `*scratch*` only. We need a custom predicate.

## Fix
Add to init.el (or to a new section in custom.el-friendly form):
```elisp
(setq persistent-scratch-scratch-buffer-p-function
      (lambda ()
        (member (buffer-name) '("scratch" "*scratch*"))))
```

This saves both — the user's `scratch` is what we actually care about; `*scratch*` is harmless.

## Verification
1. Open a buffer named `scratch`, write content.
2. Restart Emacs.
3. Confirm `scratch` exists with its content, not just `*scratch*`.
