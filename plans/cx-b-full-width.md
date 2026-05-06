# C-x b mini-frame full width

## Goal
The `C-x b` (consult-buffer) popup currently renders at 70% of the frame width. Make it full width so long buffer names are readable.

## Files
- `~/.emacs.d/init.el` line ~608 — `mini-frame-show-parameters`
- `~/.emacs.d/custom.el` line 10 — same setting

## Change
Both files set:
```elisp
(mini-frame-show-parameters '((top . 10) (width . 0.7) (left . 0.5)))
```
Change `(width . 0.7)` → `(width . 1.0)`. Keep `top` and `left`.

## Verification
- `C-x b` opens at full width
- `M-x` (also goes through mini-frame) still works
