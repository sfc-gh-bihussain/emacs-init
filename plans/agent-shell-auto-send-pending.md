# Agent-shell: auto-send pending input when agent finishes

## Goal
When the agent finishes a response and `my/agent-pending-input` is non-empty, automatically submit it as the next message instead of requiring a manual Enter from the user.

## File
- `~/.emacs.d/my-agent-shell.el`

## Approach
1. Find the right hook/transition. First, investigate:
   ```sh
   emacsclient --eval '(apropos-variable "agent-shell.*hook")'
   emacsclient --eval '(apropos-variable "shell-maker.*hook")'
   ```
   Look in the `agent-shell` source for an "after response" or busy→idle event. Likely candidates: `agent-shell-after-response-hook`, or hook into `comint-output-filter-functions` and detect a busy→idle edge.

2. If no built-in hook exists, install a `comint-output-filter-functions` listener that:
   - Tracks previous busy state buffer-locally
   - On each filter invocation, checks `(shell-maker-busy)` for transition true→false
   - On transition, calls the auto-send routine

3. Auto-send routine:
   ```elisp
   (defun my/agent-shell-auto-send-pending ()
     (when (and (derived-mode-p 'agent-shell-mode)
                (not (string-empty-p my/agent-pending-input)))
       (let ((text (string-trim my/agent-pending-input)))
         (setq my/agent-pending-input "")
         (my/agent-pending-display)
         (agent-shell--enqueue-request :prompt text))))
   ```

## Edge cases
- Don't auto-send while the user is actively typing — debounce with a small idle timer (e.g. 1s) before firing.
- If the agent fails / errors out, don't auto-send (the queued message might be context-dependent).

## Verification
1. While agent is responding, type a follow-up into the pending overlay.
2. Wait for the response to finish.
3. Confirm the follow-up is submitted automatically without pressing Enter.
