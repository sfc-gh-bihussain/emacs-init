# Agent-shell plan viewer

## Goal
Provide a keybinding to open the most recent Claude plan file in a markdown viewer. Optionally, when a new plan file is created while an agent-shell is alive, prompt the user to view it.

## Files
- `~/.emacs.d/init.el` or a new `~/.emacs.d/my-claude-plan-viewer.el`

## Approach
1. Plans live at `~/.claude/plans/*.md`. Helper:
   ```elisp
   (defun my/agent-shell-open-latest-plan ()
     "Open the most recent Claude plan file in markdown view mode."
     (interactive)
     (let* ((dir (expand-file-name "~/.claude/plans/"))
            (files (when (file-directory-p dir)
                     (directory-files dir t "\\.md$")))
            (latest (car (sort files (lambda (a b)
                                       (time-less-p (file-attribute-modification-time
                                                     (file-attributes b))
                                                    (file-attribute-modification-time
                                                     (file-attributes a))))))))
       (if latest
           (progn
             (find-file latest)
             (when (fboundp 'gfm-view-mode) (gfm-view-mode))
             (view-mode 1))
         (message "No plan files found in %s" dir))))

   (global-set-key (kbd "C-c v p") #'my/agent-shell-open-latest-plan)
   ```

2. Auto-prompt on new plan (optional):
   ```elisp
   (defvar my/claude-plan-watch-descriptor nil)

   (defun my/claude-plan--start-watch ()
     (require 'filenotify)
     (unless my/claude-plan-watch-descriptor
       (setq my/claude-plan-watch-descriptor
             (file-notify-add-watch
              (expand-file-name "~/.claude/plans/")
              '(change)
              (lambda (event)
                (when (and (eq (cadr event) 'created)
                           (string-suffix-p ".md" (caddr event)))
                  (when (y-or-n-p (format "New plan: %s. View?"
                                          (file-name-nondirectory (caddr event))))
                    (find-file (caddr event))
                    (when (fboundp 'gfm-view-mode) (gfm-view-mode))
                    (view-mode 1))))))))

   (add-hook 'agent-shell-mode-hook #'my/claude-plan--start-watch)
   ```

3. Ensure `markdown-mode` is in `package-selected-packages` so `gfm-view-mode` is available.

## Verification
1. Run `C-c v p` → most recent plan opens in `gfm-view-mode` + `view-mode`.
2. While an agent-shell is running, have the agent (or manually) write a new file to `~/.claude/plans/` → prompt appears asking to view.
