# Emacs config todo

## Bugs / quick fixes
- [ ] [`C-x b` mini-frame full width](plans/cx-b-full-width.md) — currently 70% width, want 100%
- [ ] [n/p in agent-shell pending input frame](plans/agent-shell-pending-np-keys.md) — can't type `n`/`p` while overlay is active
- [ ] [`my/insert-current-date` keybinding](plans/insert-current-date-binding.md) — `C-c d` doesn't fire in some buffers
- [ ] [`M-t M-t` in vterm](plans/vterm-meta-t-meta-t.md) — needs disambiguating what this should do
- [ ] [persistent-scratch saves the right buffer](plans/persistent-scratch-buffer-name.md) — currently targets `*scratch*` not user's `scratch`
- [ ] [`desktop-save-mode` doesn't restore](plans/desktop-save-mode.md) — windows/buffers not coming back across restarts
- [ ] [Agent-shell stale transcript on new session](plans/agent-shell-transcript-display.md) — wrong-session transcript shown at top
- [ ] [`C-l` in vterm cycles recenter positions](plans/vterm-recenter-top-bottom.md) — currently only goes to top once
- [ ] [Markdown URLs open in system browser](plans/markdown-links-open-in-browser.md) — currently open inside Emacs
- [ ] [Quick-hide keybinding for noisy buffers](plans/quick-hide-buffer-blacklist.md) — close `*Compile-Log*`, `*Warnings*`, nova posframe popups with one key

## Features
- [ ] [Auto-send pending input when agent finishes](plans/agent-shell-auto-send-pending.md)
- [ ] [Keep pending input visible after Enter (queued state)](plans/agent-shell-queued-overlay.md)
- [ ] [Type during model loading, send when ready](plans/agent-shell-input-during-loading.md)
- [ ] [Agent-shell plan viewer](plans/agent-shell-plan-viewer.md) — keybinding to open most recent plan in markdown view
- [ ] [Ibuffer with preview mode](plans/ibuffer-preview.md) — VC grouping + low-opacity floating preview frame
- [ ] [Agent-shell color scheme by repo + activity](plans/agent-shell-color-schemes.md)
- [ ] [Claude-generated plans with markdown code links](plans/claude-plans-with-code-links.md)

## Outstanding small tasks (no plan yet)
- Copy nth line of previous terminal command output
- Faster way in vterm to enable copy mode
- Mode-line: model display shows raw ID (`sonnet[1m]`) instead of human-readable name + effort level (e.g. `Sonnet 4.6 · high`)
