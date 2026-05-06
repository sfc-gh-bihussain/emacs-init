# Claude-generated plans should include markdown links to relevant code

## Goal
When Claude (the agent) generates a plan, the plan should reference specific files and line numbers as clickable markdown links so the user can jump straight from the plan to the code under discussion.

Example:
> Modify `my/agent-shell-busy-self-insert` ([my-agent-shell.el:64-73](../my-agent-shell.el#L64-L73)) to handle...

instead of just:
> Modify `my/agent-shell-busy-self-insert` (line 64) to handle...

## Where the configuration lives
This is not Emacs config — it's a Claude Code instruction. Three reasonable places:

1. **User-level memory rule** at `~/.claude/projects/-Users-bihussain--emacs-d/memory/`
   - Pros: applies across all sessions, automatically loaded
   - Cons: only affects this project; would need duplicating for other repos

2. **Global CLAUDE.md** at `~/.claude/CLAUDE.md`
   - Pros: applies globally to all projects
   - Cons: less discoverable, harder to override per-project

3. **A new Claude Code skill** that activates on plan-writing
   - Pros: reusable, can be enabled/disabled per task
   - Cons: more machinery for what is essentially one rule

Recommended: start with option 2 (global `~/.claude/CLAUDE.md`) since it's the simplest and applies everywhere.

## Approach
Add to `~/.claude/CLAUDE.md`:

```markdown
## Plan formatting

When writing plans, sub-plans, or design documents that reference code, format every file/function/line reference as a clickable markdown link using GitHub-style fragment syntax:

- Single line: `[path/to/file.el:42](path/to/file.el#L42)`
- Range: `[path/to/file.el:42-50](path/to/file.el#L42-L50)`
- Function reference (no specific line yet): `[fn-name](path/to/file.el)`

Use relative paths from the plan file's directory when the plan is checked into a repo, absolute paths otherwise.

This applies to `EnterPlanMode` plan files, sub-plan markdown files, and any other markdown design doc.
```

## Research / open questions
1. **Cursor's approach**: research what Cursor's prompt says about plan formatting and code references. Open question — search for "Cursor system prompt plan mode" or look at leaked prompts. The `emacs-skills:file-links` skill in this user's setup already points in this direction.

2. **Cursor uses**: the user's existing skill `emacs-skills:file-links` says: "When referencing files, format them as markdown links with line numbers using GitHub-style #L syntax." So the convention is already partially captured. The plan-formatting rule above formalises it for plans specifically.

3. **Tooling**: a small post-processor could rewrite plain `(file.el:42)` mentions into markdown links. Probably not worth it — better to teach the model the format.

## Verification
1. Add the rule to `~/.claude/CLAUDE.md`.
2. Start a new session, ask Claude to write a plan that references code.
3. Confirm the plan uses `[path:lineno](path#Lnnn)` format throughout.
4. Open the plan in `markdown-mode` and click a link → jumps to the code location.
