# Quick-hide keybinding for blacklisted buffers

## Goal
Bind a single key (e.g. `M-ESC` or `M-q`) that closes the current window when the visible buffer is on a blacklist of "quick to dismiss" buffers. Blacklist:
- `*Compile-Log*`
- `*Warnings*`
- nova posframe popups

If the buffer is not on the blacklist, the keybinding falls through to its default (or does nothing).

## File
- `~/.emacs.d/init.el`

## Approach
```elisp
(defvar my/quick-hide-buffer-regexps
  '("\\*Compile-Log\\*"
    "\\*Warnings\\*"
    "\\*nova-.*\\*"  ; adjust pattern after checking actual nova posframe buffer names
    ))

(defun my/quick-hide-buffer ()
  "Delete current window if visible buffer matches `my/quick-hide-buffer-regexps`."
  (interactive)
  (let ((name (buffer-name)))
    (if (cl-some (lambda (re) (string-match-p re name))
                 my/quick-hide-buffer-regexps)
        (if (one-window-p) (bury-buffer) (delete-window))
      (message "Not a quick-hide buffer: %s" name))))

(global-set-key (kbd "M-ESC") #'my/quick-hide-buffer)
;; Alternatives that don't conflict: "C-`", "<f9>", etc.
```

To find actual nova posframe buffer names, run:
```sh
emacsclient --eval '(mapcar #'"'"'buffer-name (buffer-list))'
```
when a nova posframe is visible.

## Open question
- Should the keybinding also hide the buffer (kill-buffer) or just close the window? Default is `delete-window`; `kill-buffer-and-window` is also reasonable for `*Compile-Log*` since it regenerates each compile.

## Verification
1. Trigger a byte-compile, see `*Compile-Log*` window pop up, press the key → window closes.
2. Trigger a warning, see `*Warnings*` pop up, press the key → window closes.
3. Press the key in a regular file buffer → no-op message.
