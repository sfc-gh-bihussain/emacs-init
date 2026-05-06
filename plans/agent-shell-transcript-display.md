# Agent-shell: inaccurate transcript shown when starting a new session

## Goal
When the user starts a new agent-shell session, `my/agent-shell-maybe-show-prev-transcript` inserts the most recent transcript in `<cwd>/.agent-shell/transcripts/` at the top of the buffer. The user reports the transcript shown is from the wrong session — e.g. JIRA-ticket-creation flow from a sibling worktree appears in a fresh session opened in the parent repo.

## File
- `~/.emacs.d/my-agent-shell.el` (function around lines 240–269)

## Investigation
1. From inside a fresh agent-shell buffer:
   ```sh
   emacsclient --eval '(agent-shell-cwd)'
   emacsclient --eval 'agent-shell--transcript-file'
   emacsclient --eval '(directory-files (expand-file-name ".agent-shell/transcripts" (agent-shell-cwd)) t "\\.md$")'
   ```
2. Add a temporary `(message "previous transcript: %s" prev)` line inside the function to log which file is selected.

## Suspected causes
1. `(agent-shell-cwd)` returns a directory other than the one transcripts are written to.
2. `agent-shell--transcript-file` is nil at the moment `post-command-hook` first fires, so the "exclude current" filter does nothing.
3. The function fires before the new transcript file is created on disk, so the previous-most file in the directory is from an unrelated session.

## Fix direction
Gate the function on:
- `agent-shell--transcript-file` being non-nil
- The current transcript file existing on disk (means session has actually started writing)
- The picked previous file being newer than some threshold (avoid showing weeks-old transcripts) — TBD

Optionally, add a defcustom like `my/agent-shell-show-prev-transcript-max-age-hours` (default e.g. 24) so old transcripts are skipped.

## Verification
1. Start a fresh agent-shell session in a directory with a stale transcript folder → no transcript shown (or only a fresh-enough one).
2. Restart an agent-shell session right after exiting → the just-ended session is shown as the previous transcript.
