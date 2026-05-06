# `M-t M-t` in vterm

## Goal
Make the key sequence `M-t M-t` work meaningfully in vterm. Today, `M-t` is captured by vterm and forwarded to the shell (zsh/bash transpose-words). The user wants the doubled sequence to do something — interpretation TBD.

## File
- `~/.emacs.d/my-vterm.el`

## Investigation first
```sh
emacsclient --eval '(keymap-lookup vterm-mode-map "M-t")'
emacsclient --eval '(keymap-lookup vterm-mode-map "M-T")'
```

Confirm with the user what `M-t M-t` should do. Two reasonable interpretations:
- (a) Literal double `M-t` passed to shell — already works if M-t falls through; user may just need to wait for the second keystroke.
- (b) Bind `M-t M-t` as an Emacs prefix that triggers an editor action (e.g. start vterm-copy-mode, or transpose words inside a vterm copy region).

## Fix
If (b), add to `my-vterm.el` inside the `:bind` block of the existing `use-package vterm`:
```elisp
("M-t M-t" . <some-command>)
```

## Verification
Manually press `M-t M-t` in a vterm buffer and confirm the desired behaviour.
