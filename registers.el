;;TODO: Make these bindings platform agnostic
;;--Import register bindings from file
;;--Add platform specific home path

(if (string= (system-name) "DESKTOP-24FKRDK")
    (progn
      (set-register ?i '(file . "C:/Users/User/AppData/Roaming/.emacs.d/emacs-init/emacs-init.el"))
      (set-register ?t '(file . "C:/Users/User/Documents/Tobyx"))
      (set-register ?d '(file . "C:/Users/User/Drive"))
      (set-register ?o '(file . "C:/Users/User/Downloads"))
      (set-register ?m '(file . "C:/MinGW/bin")))
  )
