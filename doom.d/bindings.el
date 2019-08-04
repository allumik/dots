;;; ~/.doom.d/bindings.el -*- lexical-binding: t; -*-

;; *** KEYBINDINGS ***

;; * MAIN *
(map! :leader :no "w f" 'golden-ratio)
(map! :leader :n "f d"
      ( lambda() (interactive) (dired default-directory)))
(map! :leader :n "b f d"
      ( lambda() (interactive)
        (kill-this-buffer)
        (dired default-directory)))
(map! :leader :n "!" 'shell-command)
(map! :leader :nv "SPC" 'persp-switch-to-buffer)
(map! :leader :nv "b b" 'switch-to-buffer)
(map! :leader :n "b w q"
      ( lambda() (interactive) (kill-this-buffer) (evil-quit)))
(map! :nv "C-<" '+multiple-cursors/evil-mc-make-cursor-here)
(map! :nvem "C-," 'iedit-mode-toggle-on-function)
(map! :leader :nv "o t" 'shell)
(map! :leader :nv "t t" 'toggle-truncate-lines)
(map! :leader :nv "b r" 'revert-buffer )

;; * NUMBERS INC *
(map! :nv "C-a" 'evil-numbers/inc-at-pt)
(map! :nv "C-A" 'evil-numbers/dec-at-pt)

;; * DIRED *
(map! :when (featurep! :feature evil +everywhere)
      :after dired :map dired-mode-map :n "<return>" 'dired-single-buffer)
(map! :when (featurep! :feature evil +everywhere)
      :after dired :map dired-mode-map :n "l" 'dired-single-buffer)
(map! :when (featurep! :feature evil +everywhere)
      :after dired :map dired-mode-map :n "h" 'dired-single-up-directory)
(map! :when (featurep! :feature evil +everywhere)
      :after dired :map dired-mode-map :n "C-c e" 'wdired-change-to-wdired-mode)
(map! :when (featurep! :feature evil +everywhere)
      :after dired :map dired-mode-map :n "N" 'dired-create-directory)
(map! :when (featurep! :feature evil +everywhere)
      :after dired :map dired-mode-map :n "C-c o" 'dired-open-file)

;; * RANGER *
;;(map! :after ranger :map ranger-mode-map "l" 'dired-single-buffer)
;;(map! :after ranger :map ranger-mode-map "h" 'dired-single-up-directory)
;;(map! :after ranger :map ranger-mode-map "ö" 'ranger-open-file-other-window)
;;(map! :after ranger :map ranger-mode-map "ü" 'ranger-open-file-vertically)
;;(map! :after ranger :map ranger-mode-map "ä" 'ranger-open-file-horizontally)
;;(map! :after ranger :map ranger-mode-map "<return>" 'ranger-open-file)
;;
;; * README *
  ;; "A nightmare of a key-binding macro that will use `evil-define-key*',
;; `define-key', `local-set-key' and `global-set-key' depending on context and
;; plist key flags (and whether evil is loaded or not). It was designed to make
;; binding multiple keys more concise, like in vim.
;; If evil isn't loaded, it will ignore evil-specific bindings.
;; States
    ;; :n  normal
    ;; :v  visual
    ;; :i  insert
    ;; :e  emacs
    ;; :o  operator
    ;; :m  motion
    ;; :r  replace
    ;; These can be combined (order doesn't matter), e.g. :nvi will apply to
    ;; normal, visual and insert mode. The state resets after the following
    ;; key=>def pair.
    ;; If states are omitted the keybind will be global.
    ;; This can be customized with `doom-evil-state-alist'.
    ;; :textobj is a special state that takes a key and two commands, one for the
    ;; inner binding, another for the outer.
;; Flags
    ;; (:mode [MODE(s)] [...])    inner keybinds are applied to major MODE(s)
    ;; (:map [KEYMAP(s)] [...])   inner keybinds are applied to KEYMAP(S)
    ;; (:map* [KEYMAP(s)] [...])  same as :map, but deferred
    ;; (:prefix [PREFIX] [...])   assign prefix to all inner keybindings
    ;; (:after [FEATURE] [...])   apply keybinds when [FEATURE] loads
    ;; (:local [...])             make bindings buffer local; incompatible with keymaps!
;; Conditional keybinds
    ;; (:when [CONDITION] [...])
    ;; (:unless [CONDITION] [...])
;; Example
    ;; (map! :map magit-mode-map
          ;; :m \"C-r\" 'do-something           ; assign C-r in motion state
          ;; :nv \"q\" 'magit-mode-quit-window  ; assign to 'q' in normal and visual states
          ;; \"C-x C-r\" 'a-global-keybind
          ;; (:when IS-MAC
           ;; :n \"M-s\" 'some-fn
           ;; :i \"M-o\" (lambda (interactive) (message \"Hi\"))))"
