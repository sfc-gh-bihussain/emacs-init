# Agent-shell: keep pending input visible after Enter (queued state)

## Goal
After pressing Enter to queue a message while the agent is busy, keep the message visible with a distinct "queued" appearance until the agent picks it up. Currently the overlay disappears the moment Enter is pressed.

## File
- `~/.emacs.d/my-agent-shell.el`

## Approach
1. Add a buffer-local list:
   ```elisp
   (defvar-local my/agent-queued-messages nil
     "List of strings already submitted via enqueue but not yet picked up by the agent.")
   ```

2. Modify `my/agent-shell-submit-or-queue` so that when busy:
   - Push `my/agent-pending-input` onto `my/agent-queued-messages`
   - Clear `my/agent-pending-input`
   - Re-render via `my/agent-pending-display` to show the queue stack

3. Update `my/agent-pending-display` to render `my/agent-queued-messages` above the active overlay area, using a dimmed/italic face:
   ```elisp
   (concat
     (mapconcat (lambda (msg)
                  (propertize (concat "  ⌛ " msg "\n")
                              'face '(:foreground "#7a8aa0" :slant italic)))
                my/agent-queued-messages
                "")
     ;; existing pending overlay below
     ...)
   ```

4. When a queued message is picked up by the agent (detected via shell output filter, or paired with the C1 auto-send mechanism), pop it from `my/agent-queued-messages` and re-render.

## Open question
- How do we detect "picked up"? Easiest: when `shell-maker-busy` transitions to true after being false, assume the head of the queue was just sent.

## Verification
1. While agent is busy, type a message and press Enter → queued indicator appears.
2. Type another, press Enter → second queued indicator appears.
3. When the current response finishes and the first queued is picked up, the first indicator disappears.
