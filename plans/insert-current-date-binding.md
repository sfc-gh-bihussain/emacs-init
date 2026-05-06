# Fix `my/insert-current-date` keybinding

## Goal
`C-c d` is supposed to insert today's date via `my/insert-current-date`, but the binding doesn't fire in (at least some) buffers. The function itself works — running it via `emacsclient --eval '(my/insert-current-date)'` inserts correctly.

## File
- `~/.emacs.d/init.el` (function and global binding around lines 46–51)

## Investigation
1. Reproduce in the affected buffer.
2. From that buffer:
   ```sh
   emacsclient --eval '(describe-key (kbd "C-c d"))'
   emacsclient --eval '(list (key-binding (kbd "C-c d")) (global-key-binding (kbd "C-c d")) (local-key-binding (kbd "C-c d")))'
   ```
3. Identify what major or minor mode shadows `C-c d`. Likely candidates: `org-mode` (`org-deadline`), `python-mode`, `markdown-mode`.

## Fix
Two options once shadowing is confirmed:
- Move the binding to a key that's unlikely to be shadowed (e.g. `C-c C-d` is rarely free; better: `C-c i d` under a personal prefix).
- Use `bind-key*` from `bind-key.el` to force a global override.

Pick option 1 or 2 based on what the user prefers.

## Verification
- After the fix, `C-c d` (or new binding) inserts the date in `org-mode`, `markdown-mode`, vterm copy mode, and any plain buffer.
