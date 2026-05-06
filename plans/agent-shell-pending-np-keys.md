# Agent-shell: n/p self-insert only inside pending input frame

## Goal
In agent-shell, lowercase `n` and `p` cannot be typed into the pending-input overlay because `agent-shell-mode-map` binds them to history navigation. The user wants:

- Cursor inside the pending input frame → `n`/`p` insert literal characters
- Cursor in history area (above the prompt) → `n`/`p` keep navigating between previous messages

The "step out" mechanism is `C-p` (not currently customised). `C-n` is already gated to not exit the pending frame downward.

## File
- `~/.emacs.d/my-agent-shell.el`

## Approach
Add a helper plus two bindings inside the existing `with-eval-after-load 'agent-shell` block:

```elisp
(defun my/agent-shell--in-pending-frame-p ()
  (and my/agent-pending-overlay
       (not (string-empty-p my/agent-pending-input))
       (>= (point) (overlay-start my/agent-pending-overlay))))

(keymap-set agent-shell-mode-map "n"
            (lambda (n) (interactive "^p")
              (if (my/agent-shell--in-pending-frame-p)
                  (my/agent-shell-busy-self-insert n ?n)
                (call-interactively #'agent-shell-next-item))))
;; same shape for "p" / ?p / agent-shell-previous-item
```

## Verification
With an agent-shell session running, while agent is busy:
1. Type `n` and `p` directly into the pending overlay → they appear as text
2. Press `C-p` to move into history, then `n`/`p` → navigate between previous messages
3. Byte-compile `my-agent-shell.el` succeeds with no new warnings
