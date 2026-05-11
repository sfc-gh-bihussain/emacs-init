# LSP references with preview

## Goal
- `M-,` triggers `lsp-find-references` (shows all usages in an xref buffer)
- Navigating through results in the xref buffer previews the usage site in another window without moving point away from the list

## Files
- `~/.emacs.d/init.el` — keybinding + xref preview config

## Approach

### Keybinding
```elisp
(with-eval-after-load 'lsp-mode
  (define-key lsp-mode-map (kbd "M-,") #'lsp-find-references))
```
`M-,` is unbound by default in most modes (it's `tags-loop-continue` in older Emacs but not commonly used).

### Preview on navigation
xref has built-in preview support via `xref-show-xrefs-function`. Use `xref-show-definitions-buffer-at-bottom` or the `consult-xref` backend for inline preview:

```elisp
;; Option A: built-in — show results at bottom, preview on M-n/M-p
(setq xref-show-xrefs-function #'xref-show-xrefs-buffer
      xref-auto-jump-to-first-xref nil)

;; Option B: consult-xref — if consult is already loaded, gives live preview
(with-eval-after-load 'consult
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref))
```

Option B is preferred since `consult` is already in use (`C-s` → `consult-line`). With `consult-xref`, navigating the candidate list live-previews the usage site.

## Open questions
- Should `M-,` work globally (any xref backend) or only in `lsp-mode` buffers? Scoping to `lsp-mode-map` is safer.
- `consult-xref` preview — verify it works with `lsp-mode`'s xref backend (it should; lsp-mode registers a standard xref provider).

## Verification
1. Open a file in `lsp-mode`, place point on a symbol, press `M-,` → references list appears.
2. Move through entries with `n`/`p` (or arrow keys) → each entry previews in a side window.
3. Press `RET` to jump to a reference; `M-,` outside `lsp-mode` → default binding (no-op or old behavior).
