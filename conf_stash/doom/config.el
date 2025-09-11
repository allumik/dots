;;; ~/.doom.d/config.el -*- lexical-binding: t; -*-
;; hlissner: Only init.el and config.el are loaded automatically. You'll have to load other files manually.
(load! "bindings.el")
(require 'dired-single)
(require 'golden-ratio)


;; TODO MAKE ALL THIS LITERATE SOMEDAY - with foldable bindings.el etc


;; *** DOOM ***

;; the configuration of all things in life
(setq
 user-full-name "Alvin Meltsov"
 user-mail-address "alvinmeltsov@gmail.com"
 ;; love-for-life-full-name "Jane Torp"
 )


;; *** FONT ***
(setq
 default-font-size 17
 default-nice-size 17
 doom-font-increment 1
 default-text-scale-amount 5
 doom-font (font-spec :family "Iosevka Term SS08"
                      :size default-font-size)
 doom-variable-pitch-font (font-spec :family "IBM Plex Sans"
                                     :size default-font-size)
 doom-big-font (font-spec :family "Iosevka SS08"
                          :size (+ default-font-size 2))
 doom-unicode-font (font-spec :family "IBM Plex Mono"
                              :size default-font-size)
 doom-serif-font (font-spec :family "IBM Plex Serif"
                            :size default-nice-size)
 )

 ;; *** Frame settings ***
(setq
 ;; frame size
 initial-frame-alist '((internal-border-width . 12))
 default-frame-alist '((internal-border-width . 12))
 ;; space between windows
 window-divider-default-right-width 8
 window-divider-default-bottom-width 6
 window-divider-default-places t  ;; put 'right/bottom-only if appropriate
 )

 ;; *** multiedit & mc ***
(setq
 evil-multiedit-follow-matches t
 evil-multiedit-store-in-search-history t
 )

 ;; *** Modeline settings ***
(setq
 doom-modeline-height 16 ; font size + 6
 doom-modeline-bar-width 3 ; the color bar at the beginning - min 1
 doom-modeline-icon t ; "nil" if the all-the-icons installer fails
 doom-modeline-enable-word-count nil
 doom-modeline-modal-icon t
 doom-modeline-major-mode-color-icon t
 doom-modeline-buffer-encoding "nondefault"
 )

;; *** Scrolling ***
;; This comes in Emacs 29 - better mouse scrolling - the future is now
(pixel-scroll-precision-mode 1)
;; scroll one line at a time (less "jumpy" than defaults)
(setq
 mouse-wheel-progressive-speed t ;; accelerate scrolling
 mouse-wheel-follow-mouse t ;; scroll window under mouse
 scroll-step 1 ;; keyboard scroll one line at a time
 )


;; *** general stuff ***
(setq
 browse-url-generic-program "google-chrome" ;; NOTE when using mac, change it
 ;; browse-url-browser-function 'browse-url-edge
 ;; remote-shell-program "/usr/bin/bash"
 ;; shell-file-name "C:\\Program Files\\PowerShell\\7\\pwsh.exe"
 ;; shell--start-prog "start "
 counsel-search-engine 'google

 x-stretch-cursor t

 custom-safe-themes t
 org-startup-folded t
 +zen-text-scale 0
 +zen-mixed-pitch-modes '(adoc-mode rst-mode org-mode)

 evil-snipe-scope 'visible
 display-line-numbers-type nil ;; 'relative
 global-git-gutter-mode t
 ;; vc-handled-backends (remove 'Git vc-handled-backends)
 remote-file-name-inhibit-cache nil
 vc-ignore-dir-regexp
      (format "%s\\|%s"
                    vc-ignore-dir-regexp
                    tramp-file-name-regexp)
 ;; tramp-verbose 1
 comint-scroll-to-bottom-on-input 'others
 comint-scroll-to-bottom-on-output 'others
 ;; recentf-auto-cleanup 'never
 delete-by-moving-to-trash t
 golden-ratio-auto-scale t
 ;; prescient-sort-length-enable nil
 prescient-persist-mode 1
 all-the-icons-scale-factor 0.8

 ;; location for auto-theme
 calendar-location-name "Tartu, Estonia"
 calendar-latitude 58.3604
 calendar-longitude 26.7214
 )
(global-subword-mode 1) ;; for those CamelCase lovers



;; *** COSMETICS ***


;; *** Dashboard ***
;; remove the doom asciiart for more minimal look
;; (setq fancy-splash-image 'nil)
(remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-banner)

;; *** Other ***
(use-package rainbow-mode ;; color hex highlighting
 :hook '(prog-mode text-mode))

;; have tighter text, especially in programming languages
(setq-hook! '(text-mode-hook prog-mode-hook)
  line-spacing 0)

;; Enable variating background colors
;; (solaire-global-mode t)
;; Enable flashing mode-line on errors
(doom-themes-visual-bell-config)


;; *** MODELINE ***
;; remove the modeline at all when running specific buffers
(setq-hook!
    '(ibuffer-mode-hook
      dired-mode-hook
      shell-mode-hook
      eshell-mode-hook
      +doom-dashboard-mode-hook)
  mode-line-format nil
  header-line-format nil)


;; *** Scrollbars & other UI ***
;; enable yascroll for all buffers - the small line atthe edge
(global-yascroll-bar-mode 1)
;; These are also possible to set with "(menu-bar-mode -1)" but it did not work in W11
(customize-set-variable 'menu-bar-mode nil)              ;; no menu bar
(customize-set-variable 'tool-bar-mode nil)              ;; no toolbar
(customize-set-variable 'scroll-bar-mode nil)            ;; no scroll bars
(customize-set-variable 'horizontal-scroll-bar-mode nil) ;; scroll bars



;; *** THEME ***

(defun fringe-bg-color ()
  "Get the background color for the fringe"
  (face-background 'default))

(defun theme-defaults ()
  "Custom face attributes and actions run after loading a theme"
  (set-face-attribute 'font-lock-comment-face nil
                      :slant 'italic)
  (set-face-attribute 'font-lock-function-name-face nil
                      :bold t)
  (set-face-attribute 'mode-line nil
                      :family "VictorMono Nerd Font"
                      :weight 'regular)
  (set-face-attribute 'mode-line-inactive nil
                      :family "VictorMono Nerd Font"
                      :weight 'regular
                      :slant 'italic)
  ;; define dividers colors - not working with modus-operandi
  (set-face-attribute 'window-divider nil
                      :background (fringe-bg-color)
                      :foreground (fringe-bg-color))
  (set-face-foreground 'window-divider-first-pixel (fringe-bg-color))
  (set-face-foreground 'window-divider-last-pixel (fringe-bg-color))
  ;; (set-face-foreground 'doom-modeline-bar-inactive (face-background 'doom-modeline-bar-inactive))
  ;; (set-face-background 'header-line (face-background 'mode-line))
  )

;; make the custom defaults apply on both automatic theme change ...
(setq theme-changer-post-change-functions (theme-defaults)
      doom-solarized-light-brighter-modeline t
      doom-solarized-light-padded-modeline t
      doom-acario-light-brighter-modeline t)
;; ... and also on arbitrary theme load
(add-hook 'doom-load-theme-hook (lambda () (theme-defaults)))

;; Set the theme
(setq doom-theme 'doom-homage-white)

;; *** persp ***
;; dont fimodus-operandias much as it does
(setq persp-add-buffer-on-after-change-major-mode t)

;; above setting will not discriminate and bring ephemeral buffers e.g.
;; *magit* which you probably don't want. You can filter them out.
(add-hook! 'persp-common-buffer-filter-functions
          ;; there is also `persp-add-buffer-on-after-change-major-mode-filter-functions'
          #'(lambda (b) (string-prefix-p "*magit" (buffer-name b)))
          #'(lambda (b) (string-prefix-p "*Messages" (buffer-name b))))



;; *** Vertico ***
(setq vertico-cycle t)


;; *** ibuffer ***

;; theres always SPC b i -> ibuffer
;; or SPC b b -> workspace ibuffer
(setq ibuffer-display-summary nil
      all-the-icons-ibuffer-human-readable-size t)
;; (add-to-list 'ibuffer-never-show-predicates "^\\*")

(defun ibuffer-remove-column-headings (&rest _args)
  "Function ran after `ibuffer-update-title-and-summary' that removes headings."
    (with-current-buffer (current-buffer)
      (goto-char 1)
      (search-forward "-\n" nil t)
      (delete-region 1 (point))))
(advice-add 'ibuffer-update-title-and-summary
            :after 'ibuffer-remove-column-headings)



;; *** ORG ***
;; disable the code length indicator for org
(after! org
  (auto-fill-mode -1)
  (setq org-startup-folded t
        org-format-latex-options (plist-put org-format-latex-options :background "Transparent")
        org-support-shift-select t
        doom-themes-org-fontify-special-tags t
        org-image-actual-width 500
        org-html-checkbox-type 'html-span
        org-ellipsis " ▾ "
        org-list-demote-modify-bullet '(("+" . "-") ("-" . "+"))
        ;; ... - Babel defaults
        ;; session will be "main", tangle "on", and output would be raw output
        ;; org-babel-default-header-args
        ;; (cons '(:tangle . "yes")
        ;;       (assq-delete-all :tangle org-babel-default-header-args))
        org-babel-default-header-args
        (cons '(:session . "main")
              (assq-delete-all :session org-babel-default-header-args))
        ;; also disable indentation as it messes up with lsp
        org-hide-emphasis-markers t     ; This removes markes from /slanted/ etc
        org-startup-indented nil))

(use-package! org-pandoc-import :after org)
(setq-default org-html-with-latex `dvisvgm) ;; might cause problems, faster

;; Since we can, instead of making the background colour match the default face, let’s make it transparent.
(add-hook! 'org-mode-hook
           #'org-fragtog-mode ;; on the fly latex rendering
           #'mixed-pitch-mode)

;; this makes the popup sub-buffer for editing code use python
(defun org-babel-edit-prep:python (babel-info)
  (setq-local buffer-file-name (->> babel-info caddr (alist-get :tangle)))
  (lsp))


;; ... - Agenda
(setq org-directory "~/Documents/Notes/orgs"
      org-agenda-files (directory-files-recursively "~/Documents/Notes/orgs" "\\orgs$")
      org-log-done t
      org-log-done-with-time t)

;; ... - Roam
(setq org-roam-directory "~/Documents/Notes/orgs/letterbox/"
      ;; citar-bibliography '("~/Documents/Biblio/zot_lib.bib")
      citar-notes-paths '("~/Documents/Notes/orgs/letterbox/")
      org-roam-database-connector 'sqlite3)


;; *** ESS ***
(add-hook! '(prog-mode-hook text-mode-hook polymode-minor-mode-hook)
           #'doom-mark-buffer-as-real-h)
(setq inferior-R-args "--vanilla")

;; syntax highlighting
(setq ess-R-font-lock-keywords
  '((ess-R-fl-keyword:keywords   . t)
    (ess-R-fl-keyword:constants  . t)
    (ess-R-fl-keyword:modifiers  . t)
    (ess-R-fl-keyword:fun-defs   . t)
    (ess-R-fl-keyword:assign-ops . t)
    (ess-R-fl-keyword:%op%       . t)
    (ess-fl-keyword:fun-calls    . t)
    (ess-fl-keyword:numbers)
    (ess-fl-keyword:operators . t)
    (ess-fl-keyword:delimiters)
    (ess-fl-keyword:=)
    (ess-R-fl-keyword:F&T)))


;; *** Markdown ***
(add-hook! 'markdown-mode-hook
           #'mixed-pitch-mode
           #'org-fragtog-mode) ;; on the fly latex rendering



;; *** GOOD COMPANY ***
;; no automatic completion, use C-x C-o
;; If you wish to reenable it, then replace "nil" with number
(setq company-idle-delay 1.2
      company-minimum-prefix-length 3)
(setq which-key-allow-multiple-replacements t)
(after! which-key
  (pushnew!
   which-key-replacement-alist
   '(("" . "\\`+?evil[-:]?\\(?:a-\\)?\\(.*\\)") . (nil . "◂\\1"))
   '(("\\`g s" . "\\`evilem--?motion-\\(.*\\)") . (nil . "◃\\1"))
   ))



;; *** DIRED ***
(setq dired-listing-switches "-aBhXl --group-directories-first")

(add-hook 'dired-mode-hook
          (lambda ()
            (dired-hide-details-mode nil)
            (dired-collapse-mode)
            (dired-utils-format-information-line-mode)))

(setq-hook! 'dired-mode-hook
  mode-line-format nil
  dired-async-mode t
  header-line-format nil)

;; *** TIPS and TRICKS ***
;; Tramp SSH connection:
;; If acting up, https://stackoverflow.com/questions/1353297/editing-remote-files-with-emacs-using-public-key-authentication
;; This means that run command "ssh-add" or something :)
