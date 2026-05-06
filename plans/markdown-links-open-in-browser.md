# Markdown links open in system browser, not Emacs

## Goal
When the user clicks a webpage URL in a markdown buffer (or hits `RET` on it), it should open in the system browser instead of `eww`/Emacs.

## File
- `~/.emacs.d/init.el` (or wherever markdown-mode is configured)

## Approach
Two settings cover this:

```elisp
(setq browse-url-browser-function 'browse-url-default-browser)
;; or on macOS, the most reliable:
(setq browse-url-browser-function 'browse-url-default-macosx-browser)
```

If `markdown-follow-link-at-point` calls `browse-url`, the above is enough. If it uses something more specific, also set:
```elisp
(with-eval-after-load 'markdown-mode
  (setq markdown-link-action #'browse-url))
```

For local-file links inside markdown (e.g. `[code](init.el)`), we want those to still open in Emacs. `markdown-mode`'s default `markdown-follow-thing-at-point` already distinguishes file paths from URLs, so this should not affect them.

## Verification
1. Open a markdown file with a webpage link, press `RET` on the link → opens in system browser.
2. Open a markdown file with a relative file link, press `RET` on it → opens in Emacs (find-file).
