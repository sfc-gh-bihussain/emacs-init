;;; 0x96f-theme.el --- Port of the Ghostty 0x96f terminal theme -*- lexical-binding: t; -*-

;;; Commentary:
;; Dark theme ported from Ghostty's `0x96f' palette.
;; Requires `autothemer'.

;;; Code:

(require 'autothemer)

(autothemer-deftheme
 0x96f "Port of the Ghostty 0x96f terminal theme."

 ((((class color) (min-colors #xFFFFFF)))

  ;; Palette (from Ghostty's 0x96f)
  (0x96f-bg          "#262427")
  (0x96f-fg          "#fcfcfa")
  (0x96f-black       "#262427")
  (0x96f-bright-black "#545452")
  (0x96f-red         "#ff666d")
  (0x96f-bright-red  "#ff7e83")
  (0x96f-green       "#b3e03a")
  (0x96f-bright-green "#bee55e")
  (0x96f-yellow      "#ffc739")
  (0x96f-bright-yellow "#ffd05e")
  (0x96f-blue        "#00cde8")
  (0x96f-bright-blue "#1bd5eb")
  (0x96f-magenta     "#a392e8")
  (0x96f-bright-magenta "#b0a3eb")
  (0x96f-cyan        "#9deaf6")
  (0x96f-bright-cyan "#acedf8")
  (0x96f-white       "#fcfcfa")
  ;; Derived (soft variants for UI chrome)
  (0x96f-bg-alt      "#2f2d30")
  (0x96f-bg-hl       "#3a373b")
  (0x96f-comment     "#7a7a78"))

 ;; Faces
 ((default                        (:foreground 0x96f-fg :background 0x96f-bg))
  (cursor                         (:background 0x96f-fg))
  (fringe                         (:background 0x96f-bg))
  (region                         (:foreground 0x96f-bg :background 0x96f-fg))
  (highlight                      (:background 0x96f-bg-hl))
  (hl-line                        (:background 0x96f-bg-alt))
  (link                           (:foreground 0x96f-cyan :underline t))
  (minibuffer-prompt              (:foreground 0x96f-blue :weight (quote bold)))
  (vertical-border                (:foreground 0x96f-bright-black))
  (show-paren-match               (:foreground 0x96f-yellow :weight (quote bold)))
  (show-paren-mismatch            (:foreground 0x96f-red :weight (quote bold)))
  (error                          (:foreground 0x96f-red))
  (warning                        (:foreground 0x96f-yellow))
  (success                        (:foreground 0x96f-green))

  ;; Mode line
  (mode-line                      (:foreground 0x96f-fg :background 0x96f-bg-hl))
  (mode-line-inactive             (:foreground 0x96f-comment :background 0x96f-bg-alt))
  (mode-line-buffer-id            (:foreground 0x96f-cyan :weight (quote bold)))

  ;; Line numbers
  (line-number                    (:foreground 0x96f-bright-black :background 0x96f-bg))
  (line-number-current-line       (:foreground 0x96f-yellow :background 0x96f-bg :weight (quote bold)))

  ;; font-lock
  (font-lock-builtin-face         (:foreground 0x96f-cyan))
  (font-lock-comment-face         (:foreground 0x96f-comment :slant (quote italic)))
  (font-lock-comment-delimiter-face (:foreground 0x96f-comment :slant (quote italic)))
  (font-lock-constant-face        (:foreground 0x96f-red))
  (font-lock-doc-face             (:foreground 0x96f-bright-green :slant (quote italic)))
  (font-lock-function-name-face   (:foreground 0x96f-blue))
  (font-lock-keyword-face         (:foreground 0x96f-magenta :weight (quote bold)))
  (font-lock-negation-char-face   (:foreground 0x96f-red))
  (font-lock-preprocessor-face    (:foreground 0x96f-magenta))
  (font-lock-regexp-grouping-backslash (:foreground 0x96f-yellow))
  (font-lock-regexp-grouping-construct (:foreground 0x96f-magenta))
  (font-lock-string-face          (:foreground 0x96f-green))
  (font-lock-type-face            (:foreground 0x96f-yellow))
  (font-lock-variable-name-face   (:foreground 0x96f-fg))
  (font-lock-warning-face         (:foreground 0x96f-bright-red :weight (quote bold)))

  ;; isearch
  (isearch                        (:foreground 0x96f-bg :background 0x96f-yellow :weight (quote bold)))
  (isearch-fail                   (:foreground 0x96f-fg :background 0x96f-red))
  (lazy-highlight                 (:foreground 0x96f-bg :background 0x96f-bright-cyan))

  ;; ivy / swiper
  (ivy-current-match              (:foreground 0x96f-bg :background 0x96f-cyan :weight (quote bold)))
  (ivy-minibuffer-match-face-1    (:foreground 0x96f-fg))
  (ivy-minibuffer-match-face-2    (:foreground 0x96f-bg :background 0x96f-yellow))
  (ivy-minibuffer-match-face-3    (:foreground 0x96f-bg :background 0x96f-green))
  (ivy-minibuffer-match-face-4    (:foreground 0x96f-bg :background 0x96f-magenta))
  (swiper-line-face               (:background 0x96f-bg-hl))
  (swiper-match-face-1            (:foreground 0x96f-fg))
  (swiper-match-face-2            (:foreground 0x96f-bg :background 0x96f-yellow))
  (swiper-match-face-3            (:foreground 0x96f-bg :background 0x96f-green))
  (swiper-match-face-4            (:foreground 0x96f-bg :background 0x96f-magenta))

  ;; company
  (company-tooltip                (:foreground 0x96f-fg :background 0x96f-bg-alt))
  (company-tooltip-selection      (:background 0x96f-bg-hl))
  (company-tooltip-common         (:foreground 0x96f-cyan :weight (quote bold)))
  (company-tooltip-annotation     (:foreground 0x96f-magenta))
  (company-scrollbar-bg           (:background 0x96f-bg-alt))
  (company-scrollbar-fg           (:background 0x96f-bright-black))

  ;; org
  (org-level-1                    (:foreground 0x96f-red    :weight (quote bold)))
  (org-level-2                    (:foreground 0x96f-yellow :weight (quote bold)))
  (org-level-3                    (:foreground 0x96f-green  :weight (quote bold)))
  (org-level-4                    (:foreground 0x96f-cyan   :weight (quote bold)))
  (org-level-5                    (:foreground 0x96f-blue   :weight (quote bold)))
  (org-level-6                    (:foreground 0x96f-magenta :weight (quote bold)))
  (org-todo                       (:foreground 0x96f-red    :weight (quote bold)))
  (org-done                       (:foreground 0x96f-green  :weight (quote bold)))
  (org-code                       (:foreground 0x96f-bright-cyan))
  (org-verbatim                   (:foreground 0x96f-bright-green))
  (org-block                      (:background 0x96f-bg-alt))

  ;; magit
  (magit-section-heading          (:foreground 0x96f-yellow :weight (quote bold)))
  (magit-branch-local             (:foreground 0x96f-cyan))
  (magit-branch-remote            (:foreground 0x96f-green))
  (magit-diff-added               (:foreground 0x96f-green  :background 0x96f-bg-alt))
  (magit-diff-added-highlight     (:foreground 0x96f-bright-green :background 0x96f-bg-hl))
  (magit-diff-removed             (:foreground 0x96f-red    :background 0x96f-bg-alt))
  (magit-diff-removed-highlight   (:foreground 0x96f-bright-red :background 0x96f-bg-hl))
  (magit-diff-context             (:foreground 0x96f-comment))
  (magit-diff-context-highlight   (:foreground 0x96f-fg :background 0x96f-bg-alt))
  (magit-hash                     (:foreground 0x96f-magenta))

  ;; diff-hl / flycheck
  (diff-hl-change                 (:foreground 0x96f-yellow :background 0x96f-yellow))
  (diff-hl-insert                 (:foreground 0x96f-green  :background 0x96f-green))
  (diff-hl-delete                 (:foreground 0x96f-red    :background 0x96f-red))
  (flycheck-error                 (:underline (:style (quote wave) :color "#ff666d")))
  (flycheck-warning               (:underline (:style (quote wave) :color "#ffc739")))
  (flycheck-info                  (:underline (:style (quote wave) :color "#9deaf6")))

  ;; tree-sitter (shared names)
  (tree-sitter-hl-face:function         (:foreground 0x96f-blue))
  (tree-sitter-hl-face:function.call    (:foreground 0x96f-blue))
  (tree-sitter-hl-face:method.call      (:foreground 0x96f-blue))
  (tree-sitter-hl-face:type             (:foreground 0x96f-yellow))
  (tree-sitter-hl-face:keyword          (:foreground 0x96f-magenta :weight (quote bold)))
  (tree-sitter-hl-face:string           (:foreground 0x96f-green))
  (tree-sitter-hl-face:number           (:foreground 0x96f-red))
  (tree-sitter-hl-face:variable         (:foreground 0x96f-fg))
  (tree-sitter-hl-face:variable.parameter (:foreground 0x96f-bright-cyan))
  (tree-sitter-hl-face:property         (:foreground 0x96f-bright-cyan))

  ;; term / vterm / eshell - map the 16 ANSI colours
  (term-color-black               (:foreground 0x96f-black   :background 0x96f-black))
  (term-color-red                 (:foreground 0x96f-red     :background 0x96f-red))
  (term-color-green               (:foreground 0x96f-green   :background 0x96f-green))
  (term-color-yellow              (:foreground 0x96f-yellow  :background 0x96f-yellow))
  (term-color-blue                (:foreground 0x96f-blue    :background 0x96f-blue))
  (term-color-magenta             (:foreground 0x96f-magenta :background 0x96f-magenta))
  (term-color-cyan                (:foreground 0x96f-cyan    :background 0x96f-cyan))
  (term-color-white               (:foreground 0x96f-white   :background 0x96f-white))))

(custom-theme-set-variables
 '0x96f
 '(ansi-color-names-vector
   ["#262427" "#ff666d" "#b3e03a" "#ffc739"
    "#00cde8" "#a392e8" "#9deaf6" "#fcfcfa"]))

(provide-theme '0x96f)


;; ─────────────────────────────────────────────────────────────────────────────
;; High-contrast variant: pure-black bg, pushed-saturation palette.
;; Designed to look more vibrant on sRGB-only displays.
;; ─────────────────────────────────────────────────────────────────────────────

(autothemer-deftheme
 0x96f-vivid "High-contrast / pushed-saturation variant of 0x96f."

 ((((class color) (min-colors #xFFFFFF)))

  (0x96f-bg          "#000000")
  (0x96f-fg          "#ffffff")
  (0x96f-black       "#000000")
  (0x96f-bright-black "#666666")
  (0x96f-red         "#ff2050")
  (0x96f-bright-red  "#ff5070")
  (0x96f-green       "#7fff00")
  (0x96f-bright-green "#a0ff20")
  (0x96f-yellow      "#ffd700")
  (0x96f-bright-yellow "#ffe060")
  (0x96f-blue        "#00ffff")
  (0x96f-bright-blue "#40ffff")
  (0x96f-magenta     "#c060ff")
  (0x96f-bright-magenta "#d080ff")
  (0x96f-cyan        "#80ffff")
  (0x96f-bright-cyan "#a0ffff")
  (0x96f-white       "#ffffff")
  (0x96f-bg-alt      "#0a0a0a")
  (0x96f-bg-hl       "#1a1a1a")
  (0x96f-comment     "#808080"))

 ((default                        (:foreground 0x96f-fg :background 0x96f-bg))
  (cursor                         (:background 0x96f-fg))
  (fringe                         (:background 0x96f-bg))
  (region                         (:foreground 0x96f-bg :background 0x96f-fg))
  (highlight                      (:background 0x96f-bg-hl))
  (hl-line                        (:background 0x96f-bg-alt))
  (link                           (:foreground 0x96f-cyan :underline t))
  (minibuffer-prompt              (:foreground 0x96f-blue :weight (quote bold)))
  (vertical-border                (:foreground 0x96f-bright-black))
  (show-paren-match               (:foreground 0x96f-yellow :weight (quote bold)))
  (show-paren-mismatch            (:foreground 0x96f-red :weight (quote bold)))
  (error                          (:foreground 0x96f-red))
  (warning                        (:foreground 0x96f-yellow))
  (success                        (:foreground 0x96f-green))

  (mode-line                      (:foreground 0x96f-fg :background 0x96f-bg-hl))
  (mode-line-inactive             (:foreground 0x96f-comment :background 0x96f-bg-alt))
  (mode-line-buffer-id            (:foreground 0x96f-cyan :weight (quote bold)))

  (line-number                    (:foreground 0x96f-bright-black :background 0x96f-bg))
  (line-number-current-line       (:foreground 0x96f-yellow :background 0x96f-bg :weight (quote bold)))

  (font-lock-builtin-face         (:foreground 0x96f-cyan))
  (font-lock-comment-face         (:foreground 0x96f-comment :slant (quote italic)))
  (font-lock-comment-delimiter-face (:foreground 0x96f-comment :slant (quote italic)))
  (font-lock-constant-face        (:foreground 0x96f-red))
  (font-lock-doc-face             (:foreground 0x96f-bright-green :slant (quote italic)))
  (font-lock-function-name-face   (:foreground 0x96f-blue))
  (font-lock-keyword-face         (:foreground 0x96f-magenta :weight (quote bold)))
  (font-lock-negation-char-face   (:foreground 0x96f-red))
  (font-lock-preprocessor-face    (:foreground 0x96f-magenta))
  (font-lock-regexp-grouping-backslash (:foreground 0x96f-yellow))
  (font-lock-regexp-grouping-construct (:foreground 0x96f-magenta))
  (font-lock-string-face          (:foreground 0x96f-green))
  (font-lock-type-face            (:foreground 0x96f-yellow))
  (font-lock-variable-name-face   (:foreground 0x96f-fg))
  (font-lock-warning-face         (:foreground 0x96f-bright-red :weight (quote bold)))

  (isearch                        (:foreground 0x96f-bg :background 0x96f-yellow :weight (quote bold)))
  (isearch-fail                   (:foreground 0x96f-fg :background 0x96f-red))
  (lazy-highlight                 (:foreground 0x96f-bg :background 0x96f-bright-cyan))

  (ivy-current-match              (:foreground 0x96f-bg :background 0x96f-cyan :weight (quote bold)))
  (ivy-minibuffer-match-face-1    (:foreground 0x96f-fg))
  (ivy-minibuffer-match-face-2    (:foreground 0x96f-bg :background 0x96f-yellow))
  (ivy-minibuffer-match-face-3    (:foreground 0x96f-bg :background 0x96f-green))
  (ivy-minibuffer-match-face-4    (:foreground 0x96f-bg :background 0x96f-magenta))
  (swiper-line-face               (:background 0x96f-bg-hl))
  (swiper-match-face-1            (:foreground 0x96f-fg))
  (swiper-match-face-2            (:foreground 0x96f-bg :background 0x96f-yellow))
  (swiper-match-face-3            (:foreground 0x96f-bg :background 0x96f-green))
  (swiper-match-face-4            (:foreground 0x96f-bg :background 0x96f-magenta))

  (company-tooltip                (:foreground 0x96f-fg :background 0x96f-bg-alt))
  (company-tooltip-selection      (:background 0x96f-bg-hl))
  (company-tooltip-common         (:foreground 0x96f-cyan :weight (quote bold)))
  (company-tooltip-annotation     (:foreground 0x96f-magenta))
  (company-scrollbar-bg           (:background 0x96f-bg-alt))
  (company-scrollbar-fg           (:background 0x96f-bright-black))

  (org-level-1                    (:foreground 0x96f-red    :weight (quote bold)))
  (org-level-2                    (:foreground 0x96f-yellow :weight (quote bold)))
  (org-level-3                    (:foreground 0x96f-green  :weight (quote bold)))
  (org-level-4                    (:foreground 0x96f-cyan   :weight (quote bold)))
  (org-level-5                    (:foreground 0x96f-blue   :weight (quote bold)))
  (org-level-6                    (:foreground 0x96f-magenta :weight (quote bold)))
  (org-todo                       (:foreground 0x96f-red    :weight (quote bold)))
  (org-done                       (:foreground 0x96f-green  :weight (quote bold)))
  (org-code                       (:foreground 0x96f-bright-cyan))
  (org-verbatim                   (:foreground 0x96f-bright-green))
  (org-block                      (:background 0x96f-bg-alt))

  (magit-section-heading          (:foreground 0x96f-yellow :weight (quote bold)))
  (magit-branch-local             (:foreground 0x96f-cyan))
  (magit-branch-remote            (:foreground 0x96f-green))
  (magit-diff-added               (:foreground 0x96f-green  :background 0x96f-bg-alt))
  (magit-diff-added-highlight     (:foreground 0x96f-bright-green :background 0x96f-bg-hl))
  (magit-diff-removed             (:foreground 0x96f-red    :background 0x96f-bg-alt))
  (magit-diff-removed-highlight   (:foreground 0x96f-bright-red :background 0x96f-bg-hl))
  (magit-diff-context             (:foreground 0x96f-comment))
  (magit-diff-context-highlight   (:foreground 0x96f-fg :background 0x96f-bg-alt))
  (magit-hash                     (:foreground 0x96f-magenta))

  (diff-hl-change                 (:foreground 0x96f-yellow :background 0x96f-yellow))
  (diff-hl-insert                 (:foreground 0x96f-green  :background 0x96f-green))
  (diff-hl-delete                 (:foreground 0x96f-red    :background 0x96f-red))
  (flycheck-error                 (:underline (:style (quote wave) :color "#ff2050")))
  (flycheck-warning               (:underline (:style (quote wave) :color "#ffd700")))
  (flycheck-info                  (:underline (:style (quote wave) :color "#80ffff")))

  (tree-sitter-hl-face:function         (:foreground 0x96f-blue))
  (tree-sitter-hl-face:function.call    (:foreground 0x96f-blue))
  (tree-sitter-hl-face:method.call      (:foreground 0x96f-blue))
  (tree-sitter-hl-face:type             (:foreground 0x96f-yellow))
  (tree-sitter-hl-face:keyword          (:foreground 0x96f-magenta :weight (quote bold)))
  (tree-sitter-hl-face:string           (:foreground 0x96f-green))
  (tree-sitter-hl-face:number           (:foreground 0x96f-red))
  (tree-sitter-hl-face:variable         (:foreground 0x96f-fg))
  (tree-sitter-hl-face:variable.parameter (:foreground 0x96f-bright-cyan))
  (tree-sitter-hl-face:property         (:foreground 0x96f-bright-cyan))

  (term-color-black               (:foreground 0x96f-black   :background 0x96f-black))
  (term-color-red                 (:foreground 0x96f-red     :background 0x96f-red))
  (term-color-green               (:foreground 0x96f-green   :background 0x96f-green))
  (term-color-yellow              (:foreground 0x96f-yellow  :background 0x96f-yellow))
  (term-color-blue                (:foreground 0x96f-blue    :background 0x96f-blue))
  (term-color-magenta             (:foreground 0x96f-magenta :background 0x96f-magenta))
  (term-color-cyan                (:foreground 0x96f-cyan    :background 0x96f-cyan))
  (term-color-white               (:foreground 0x96f-white   :background 0x96f-white))))

(custom-theme-set-variables
 '0x96f-vivid
 '(ansi-color-names-vector
   ["#000000" "#ff2050" "#7fff00" "#ffd700"
    "#00ffff" "#c060ff" "#80ffff" "#ffffff"]))

(provide-theme '0x96f-vivid)

;;; 0x96f-theme.el ends here
