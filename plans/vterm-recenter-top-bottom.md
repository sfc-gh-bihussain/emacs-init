# `C-l` in vterm: cycle recenter positions

## Goal
In a normal Emacs buffer, `C-l` (`recenter-top-bottom`) cycles cursor line position: middle → top → bottom → middle. In vterm it only moves the prompt to the top.

## File
- `~/.emacs.d/my-vterm.el`

## Investigation
```sh
emacsclient --eval '(keymap-lookup vterm-mode-map "C-l")'
```

Likely cause: `C-l` is bound to `vterm--self-insert` (passes to shell — runs `clear`) or to `vterm-clear`. Either way it bypasses `recenter-top-bottom`.

## Fix
Add to `my-vterm.el` inside the `use-package vterm :bind` block:
```elisp
("C-l" . recenter-top-bottom)
```

If the user wants the shell `clear` behaviour preserved as well, wrap it:
```elisp
(defun my/vterm-clear-or-recenter (&optional arg)
  "Recenter; on consecutive presses cycle, on prefix arg pass C-l to shell."
  (interactive "P")
  (if arg
      (vterm-send-key "l" nil nil t)  ; literal C-l to shell
    (recenter-top-bottom)))
```

Pick the simpler version unless the user asks for both.

## Verification
- Press `C-l` repeatedly in a vterm buffer; cursor line cycles middle/top/bottom.
- (If wrapper variant chosen) `C-u C-l` invokes shell-level clear.
