# Agent-shell: type during model loading, send when ready

## Goal
The user wants to start typing the moment they hit `C-c a` (or `C-c A`) to launch agent-shell, even before the model has finished initializing. The text accumulates as a pending input and is submitted automatically when the session is ready.

## File
- `~/.emacs.d/my-agent-shell.el`

## Approach
This builds on the existing `my/agent-pending-input` overlay mechanism in `my-agent-shell.el`. Two pieces:

1. **Capture keystrokes during loading.** The `<remap> <self-insert-command>` redirect already triggers when `(shell-maker-busy)` is true OR `my/agent-pending-input` is non-empty. The "loading" phase between session start and first prompt likely has `shell-maker-busy` already true. Verify by:
   ```sh
   emacsclient --eval '(shell-maker-busy)'
   ```
   right after starting an agent-shell. If it's already true, the existing mechanism captures keystrokes correctly.

   If it's nil during loading, add an additional gate: `agent-shell--state` may have a `:session :id` field that's nil until ready. Use that as a "loading" signal.

2. **Submit when ready.** Hook into the same busy→idle transition logic from C1 (auto-send-pending). When the session becomes ready and pending input exists, submit it automatically.

   Alternatively, watch for the first non-empty agent output and submit at that point.

## Verification
1. Press `C-c a` to start agent-shell.
2. Immediately start typing — text appears in the pending overlay even though no prompt is rendered yet.
3. Once the session is ready, the typed text is submitted automatically.
