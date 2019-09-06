(setq inhibit-startup-message t)

;; Speed up load

(defvar gc-cons-threshold--orig gc-cons-threshold)
(setq gc-cons-threshold (* 100 1024 1024)
      gc-cons-percentage 0.6
      file-name-handler-alist nil)

(defun rag-set-gc-threshold ()
  "Reset `gc-cons-threshold' and `gc-cons-percentage' to their default values."
  (setq gc-cons-threshold gc-cons-threshold--orig
        gc-cons-percentage 0.1
        file-name-handler-alist rag--file-name-handler-alist))

