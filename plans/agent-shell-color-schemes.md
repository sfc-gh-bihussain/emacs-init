# Agent-shell: color scheme by repo + activity

## Goal
Each agent-shell buffer picks a unique color scheme based on:
- (a) the repo it was opened in (so different worktrees are visually distinct)
- (b) the current activity: planning, implementing, emacs config, code review

## File
- `~/.emacs.d/my-agent-shell.el` (or a new `~/.emacs.d/my-agent-shell-colors.el`)

## Approach

### 1. Per-repo color
Identify project root when agent-shell starts:
```elisp
(defun my/agent-shell--project-root ()
  (or (and (fboundp 'projectile-project-root) (projectile-project-root))
      (locate-dominating-file default-directory ".git")
      default-directory))
```

Hash to an HSL hue (0–360) deterministically:
```elisp
(defun my/agent-shell--hue-for-path (path)
  (let* ((s (md5 path))
         (n (string-to-number (substring s 0 8) 16)))
    (mod n 360)))
```

Convert to a hex color (use `hsl-to-rgb` from `color.el`).

### 2. Per-activity tinting (palette)
```elisp
(defvar my/agent-shell-activity-colors
  '((planning   . "#a78bfa")  ; violet
    (implementing . "#22c55e") ; green
    (emacs-config . "#f59e0b") ; amber
    (code-review  . "#ef4444"))) ; red
```

### 3. Activity detection
Multi-strategy with fallback:
- **Path-based**: `default-directory` under `~/.emacs.d` ⇒ `emacs-config`
- **Slash command**: scan last user input for `/plan`, `/review`, `/implement`
- **Manual**: `C-c m` cycles activity for the current buffer
Store activity buffer-locally as `my/agent-shell-activity`.

### 4. Apply colors via face remapping
```elisp
(defun my/agent-shell-apply-colors ()
  (let* ((hue (my/agent-shell--hue-for-path (my/agent-shell--project-root)))
         (header-bg (color-rgb-to-hex
                     ... ; convert HSL(hue, 0.4, 0.2) to RGB
                     ))
         (activity-color (cdr (assq my/agent-shell-activity
                                    my/agent-shell-activity-colors))))
    (face-remap-add-relative 'header-line `(:background ,header-bg))
    (face-remap-add-relative 'mode-line   `(:foreground ,activity-color))
    (setq cursor-color activity-color)))

(add-hook 'agent-shell-mode-hook #'my/agent-shell-apply-colors)
```

### 5. Persistence
Save `repo→hue` mapping to `~/.emacs.d/var/agent-shell-colors.eld` so the same repo always lands on the same color (handles cases where the user wants to override a particular project's color manually).

## Open question
- Which face attributes to remap: `header-line`, `mode-line`, `cursor`, custom `agent-shell-frame-face`. Pick what's distinctive without fighting the doom theme — start with header-line (per-repo) + mode-line accent (per-activity).

## Verification
1. Open agent-shell in two different repos → different header-line colors.
2. Switch activity (via `/plan` or `C-c m`) → mode-line accent and cursor color change.
3. Reopen the same repo → same header-line color as before (persistence).
