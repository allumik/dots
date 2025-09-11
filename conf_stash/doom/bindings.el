;;; ~/.doom.d/bindings.el -*- lexical-binding: t; -*-

;; *** Readme ***
;; States
    ;; :n  normal
    ;; :v  visual
    ;; :i  insert
    ;; :e  emacs
    ;; :o  operator
    ;; :m  motion
    ;; :r  replace
;; Flags
    ;; (:mode [MODE(s)] [...])    inner keybinds are applied to major MODE(s)
    ;; (:map [KEYMAP(s)] [...])   inner keybinds are applied to KEYMAP(S)
    ;; (:map* [KEYMAP(s)] [...])  same as :map, but deferred
    ;; (:prefix [PREFIX] [...])   assign prefix to all inner keybindings
    ;; (:after [FEATURE] [...])   apply keybinds when [FEATURE] loads
    ;; (:local [...])             make bindings buffer local; incompatible with keymaps!


;; *** Functions ***
(defun dired-open-file ()
  "In dired, open the file named on this line."
  (interactive)
  (let* ((file (dired-get-filename nil t)))
    (message "Opening %s..." file)
    (call-process "start" nil 0 nil file)
    (message "Opening %s done" file)))

;; define a function for starting experinmental lsp support in org mode blocks
(defun org-start-lsp ()
  "Start LSP for org mode code blocks"
  (interactive)
  (require 'lsp-mode)
  (lsp-org))


;; *** KEYBINDINGS ***

;; disable keybinds
;; (map! (:after ivy (:map ivy-mode-map "SPC" nil))) ;
(map!
 :nv         "M-'" nil
 :leader :nv "w W" nil)
;; (map! :nve "C-M-=" nil  ;; remove the text resizer of doom emacs and opt for
;;       :nve "C-M--" nil) ;; the 'default-text-scale-increase' command

;; Code/General
(map!
 "C-s"           #'consult-line
 "M-a"           #'align-regexp
;;  :nve "C-M-=" #'default-text-scale-increase
;;  :nve "C-M--" #'default-text-scale-decrease
 :nv "C-a"       #'evil-numbers/inc-at-pt
 :nv "C-q"       #'evil-numbers/dec-at-pt
 :nv "M-n"       #'evil-mc-make-and-goto-next-match
 :nv "M-N"       #'evil-mc-skip-and-goto-next-match
 :nv "M-p"       #'evil-mc-make-and-goto-prev-match
 :nv "M-P"       #'evil-mc-make-and-goto-prev-match
 (:leader
  ;; :nv "s a"      #'swiper-all
  :v  "m A"      #'align-regexp
  :v  "m a"      #'evil-multiedit-match-all
  :nv "m r"      #'evil-multiedit-restore
  :n  "w g"      #'golden-ratio
  :n  "w G"      #'golden-ratio-mode
  :n  "f F"      #'doom/sudo-find-file
  ;; :n  "s f"      #'counsel-fzf
  ;; :n  "f ."   #'(lambda() (interactive) (dired default-directory))
  :n  "b q"      #'(lambda() (interactive) (kill-this-buffer) (dired default-directory))
  :n  "!"        #'shell-command
  ;; :nv "b b"      #'(lambda (arg) (interactive "P") (with-persp-buffer-list () (ibuffer-jump)))
  ;; "SPC"          #'+ivy/switch-workspace-buffer
  "SPC"          #'switch-to-buffer
  :n  "b w q"    #'(lambda() (kill-this-buffer) (evil-quit))
  :nv "t t"      #'toggle-truncate-lines
  ;; "@"            #'counsel-search
  ;; "o t"          #'vterm-other-window
  "w w"          #'ace-select-window
  "w W"          #'ace-swap-window
  "w TAB"        #'evil-window-next
  "w <backtab>"  #'evil-window-prev
  )
 )

;; command for starting lsp in org-mode buffer for code blocks
(map! :after org :leader :nv "r l" #'org-start-lsp)


;; Ex command that allows you to invoke evil-multiedit with a regular expression, e.g.
;; TODO make this into an interactive command ie like search in kakoune
(evil-ex-define-cmd "s" #'evil-multiedit-ex-match)

;; * PDF *
(map!
 (:after pdf-view-mode
  (:map pdf-view-mode-map
   "<right>" #'image-scroll-right
   "<left>"  #'image-scroll-left)))

;; * DIRED *
;; disable keybinds
(map!
 (:after dired
  (:map dired-mode-map
   :n "<return>" #'dired-single-buffer
   :n "l"        #'dired-single-buffer
   :n "h"        #'dired-single-up-directory
   :n "<right>"  #'dired-single-buffer
   :n "<left>"   #'dired-single-up-directory
   :n "N"        #'dired-create-directory
   "C-c C-y"     #'dired-ranger-copy
   "C-c C-d"     #'dired-ranger-move
   "C-c C-p"     #'dired-ranger-paste
   "C-c C-e"     #'wdired-change-to-wdired-mode
   "C-c C-o"     #'dired-open-file
   "C-c C-f"     #'dired-filter-by-extension
   )
  )
 )

;;; Directional madness
(map!
 :n  "C-w <right>"   #'evil-window-right
 :n  "C-w <left>"    #'evil-window-left
 :n  "C-w <up>"      #'evil-window-up
 :n  "C-w <down>"    #'evil-window-down
 :n  "C-w S-<right>" #'+evil/window-move-right
 :n  "C-w S-<left>"  #'+evil/window-move-left
 :n  "C-w S-<up>"    #'+evil/window-move-up
 :n  "C-w S-<down>"  #'+evil/window-move-down
 :nv "C-j"           #'evil-forward-paragraph
 :nv "C-k"           #'evil-backward-paragraph
 ;; :nvo "C-h"           #'evil-backward-word-begin
 ;; :nvo "C-l"           #'evil-forward-word-end
 (:leader
  :n "w <right>"     #'evil-window-right
  :n "w <left>"      #'evil-window-left
  :n "w <up>"        #'evil-window-up
  :n "w <down>"      #'evil-window-down
  :n "w S-<right>"   #'+evil/window-move-right
  :n "w S-<left>"    #'+evil/window-move-left
  :n "w S-<up>"      #'+evil/window-move-up
  :n "w S-<down>"    #'+evil/window-move-down
  )
 )
