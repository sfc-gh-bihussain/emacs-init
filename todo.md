# Emacs config todo

## Bugs / quick fixes

### Quick wins (trivial changes)
- [ ] [`C-l` in vterm cycles recenter positions](plans/vterm-recenter-top-bottom.md) — currently only goes to top once
- [x] [Markdown URLs open in system browser](plans/markdown-links-open-in-browser.md) — one `setq browse-url-browser-function` line
- [x] `my/set-font-by-screen-size` undefined — removed dead call; `my/adjust-font-by-monitor` already runs at startup via dispwatch

### Needs investigation
- [ ] Agent-shell wrapped input cut off by mode-line — when typed input wraps to a new line, ~80% of that line is hidden behind the mode-line; likely a `window-text-height` / padding calculation issue in `my-agent-shell.el`
- [ ] [Nova buffer shrinks on keypress](plans/nova-buffer-shrink.md) — typing causes frame to resize by a fixed amount; likely `post-command-hook` or `window-size-change` recalculating child-frame size
- [ ] [`my/insert-current-date` keybinding](plans/insert-current-date-binding.md) — `C-c d` doesn't fire in some buffers
- [ ] [Agent-shell stale transcript on new session](plans/agent-shell-transcript-display.md) — wrong-session transcript shown at top
- [ ] [n/p in agent-shell pending input frame](plans/agent-shell-pending-np-keys.md) — can't type `n`/`p` while overlay is active
- [ ] [persistent-scratch saves the right buffer](plans/persistent-scratch-buffer-name.md) — currently targets `*scratch*` not user's `scratch`
- [ ] Mode-line model display shows raw ID — `sonnet[1m]` instead of human-readable name + effort level (e.g. `Sonnet 4.6 · high`)

### Complex / deprioritised
- [ ] [`desktop-save-mode` doesn't restore](plans/desktop-save-mode.md) — windows/buffers not coming back across restarts

## Features
- [x] Generalise `M-'` buffer dump
- [ ] [Agent-shell picker](plans/agent-shell-picker.md) — `C-c a` shows completing-read of live shells with title + last user message; `[New shell]` option to start fresh
- [ ] Floating input preview while scrolled — generic package for vterm + agent-shell (comint-like modes): capture keypresses while scrolled up, show typed text in a floating frame pinned to the bottom of the window, send on `RET` without snapping the scroll position; prevents buffer jumping to bottom on each keypress
- [ ] [LSP references with preview](plans/lsp-references-preview.md) — `M-,` to show references; navigating results buffer live-previews each usage site
- [ ] [Auto-send pending input when agent finishes](plans/agent-shell-auto-send-pending.md)
- [ ] [Keep pending input visible after Enter (queued state)](plans/agent-shell-queued-overlay.md)
- [ ] [Type during model loading, send when ready](plans/agent-shell-input-during-loading.md)
- [ ] [Agent-shell plan viewer](plans/agent-shell-plan-viewer.md) — keybinding to open most recent plan in markdown view
- [ ] [Agent-shell color scheme by repo + activity](plans/agent-shell-color-schemes.md)
- [ ] [Claude-generated plans with markdown code links](plans/claude-plans-with-code-links.md)
- [ ] [Ibuffer with preview mode](plans/ibuffer-preview.md) — VC grouping + low-opacity floating preview frame

## Outstanding / needs decision
- `M-t M-t` in vterm — [plan exists](plans/vterm-meta-t-meta-t.md) but needs deciding what it should actually do
- Install `markdown-xwidget` — blocked by `url."ssh://git@github.com/".insteadOf` in `~/.gitconfig` routing HTTPS clones through Snowflake proxy
- Copy nth line of previous terminal command output
- Faster way in vterm to enable copy mode
