# Agent-shell picker with last user message

## Goal
`C-c a` opens a `completing-read` showing all live agent-shell buffers. Each candidate shows the buffer title and the last user message, so the user can see at a glance what each shell was working on. A "New shell" option is always present at the top.

## Files
- `~/.emacs.d/my-agent-shell.el` — replace `my/agent-shell-start` or add a new dispatcher

## Approach

### Extract last user message
```elisp
(defun my/agent-shell-last-user-message (buf)
  "Return last non-empty user message from agent-shell BUF, or nil."
  (with-current-buffer buf
    (let* ((txt (buffer-substring-no-properties (point-min) (point-max)))
           (lines (split-string txt "\n"))
           (prompt-lines (seq-filter
                          (lambda (l) (and (string-prefix-p "❯ " l)
                                           (> (length l) 2)))
                          lines)))
      (when prompt-lines
        (substring (car (last prompt-lines)) 2)))))
```

### Picker
```elisp
(defun my/agent-shell-open-or-start ()
  "Switch to an existing agent-shell or start a new one."
  (interactive)
  (let* ((shells (seq-filter (lambda (b)
                               (with-current-buffer b
                                 (derived-mode-p 'agent-shell-mode)))
                             (buffer-list)))
         (new-label "[New shell]")
         (candidates
          (cons new-label
                (mapcar (lambda (b)
                          (let ((msg (my/agent-shell-last-user-message b)))
                            (propertize
                             (if msg
                                 (format "%s  |  %s" (buffer-name b) msg)
                               (buffer-name b))
                             'agent-shell-buf b)))
                        shells)))
         (choice (completing-read "Agent shell: " candidates nil t)))
    (if (string= choice new-label)
        (my/agent-shell-start)
      (switch-to-buffer (get-text-property 0 'agent-shell-buf choice)))))
```

### Keybinding
Change the `C-c a` binding in `use-package agent-shell` from `my/agent-shell-start` to `my/agent-shell-open-or-start`. If there are no existing shells, it falls through to `my/agent-shell-start` directly.

## Verification
1. Open two agent-shell buffers, send a message in each.
2. Press `C-c a` from any buffer → completion list shows both with their last messages.
3. Select an existing one → switches to it.
4. Select `[New shell]` → starts a new shell in `default-directory`.
5. Press `C-c a` with no existing shells → goes directly to new shell (skips picker).
