;;; config_scraps.el -*- lexical-binding: t; -*-

;; make the window divider dissappear
(defun get-bg-color ()
  (face-attribute 'default :background))

(set-face-attribute 'window-divider nil
                    :foreground (get-bg-color))
(set-face-attribute 'window-divider-first-pixel nil
                    :foreground (get-bg-color))
(set-face-attribute 'window-divider-last-pixel nil
                    :foreground (get-bg-color))

(defun load-jbeans-w-defaults ()
  "Load the Jellybeans theme with good defaults"
  (load-theme 'jbeans)
  (set-face-attribute 'italic nil :slant 'italic :underline nil)
  (set-face-attribute 'bold-italic nil
                      :inherit '(bold italic) :underline nil)
  (set-face-attribute 'bold-italic nil
                      :inherit '(bold italic) :underline nil)


  (after! org
    (set-face-attribute 'org-ellipsis nil :underline nil)
    (set-face-attribute 'org-quote nil :slant 'italic :extend t)
    )

  (after! dired
    (use-package dired-rainbow
      :config
      (progn
        (dired-rainbow-define vc "dodgerblue" ("git" "gitignore" "gitattributes" "gitmodules"))
        (dired-rainbow-define compressed "darkorange" ("7z" "zip" "bz2" "tgz" "txz" "gz" "xz" "z" "Z" "jar" "war" "ear" "rar" "sar" "xpi" "apk" "xz" "tar"))
        (dired-rainbow-define-chmod executable-unix "darkseagreen" "-[rw-]+x.*")
        (dired-rainbow-define-chmod directory (:bold t :foreground "peru") "drwxrwxrwx")))
    )
  )

;; ;; *** Jellybeans theme ***
;; (load-jbeans-w-defaults)

;; (require 'dashboard)
;; (dashboard-setup-startup-hook)
;; (setq dashboard-items '((recents  . 5)
;;                         (agenda . 5)
;;                         (bookmarks . 5))
;;       dashboard-startup-banner 'logo
;;       dashboard-week-agenda t
;;       dashboard-set-heading-icons t
;;       dashboard-set-file-icons t)


;; jupyter legacy
;; (add-hook 'ein:notebook-mode-hook
;;           (lambda ()
;;             (turn-on-undo-tree-mode)
;;             (toggle-truncate-lines)
;;             (visual-line-mode t)))


