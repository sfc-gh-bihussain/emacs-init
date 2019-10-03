(setq
 backup-by-copying t      ; don't clobber symlinks
 backup-directory-alist
 '(("." . "~/.saves/"))    ; don't litter my fs tree
 delete-old-versions t
 kept-new-versions 6
 kept-old-versions 2)

(if (string= (system-name) "DESKTOP-24FKRDK")
    (progn (setq default-directory "C:/Users/User/" )
	   (setenv "HOME"  "C:/Users/User" ))
  )

(setq load-prefer-newer t)

(desktop-save-mode 1)

(defalias 'yes-or-no-p 'y-or-n-p)
