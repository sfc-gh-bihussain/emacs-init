;;; 0x96f-vivid-theme.el --- High-contrast variant of 0x96f -*- lexical-binding: t; -*-

;;; Commentary:
;; The actual theme definition lives in `0x96f-theme.el' alongside the
;; original.  This file just loads it so `load-theme' resolves the name.

;;; Code:

(load (expand-file-name "0x96f-theme" (file-name-directory load-file-name)) nil t)

;;; 0x96f-vivid-theme.el ends here
