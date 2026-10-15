;; Guix Home for allu and jane on deskmeat. The configs themselves are the
;; tools' own files: dotfiles/ mirrors $HOME, and the ones shared with NixOS
;; stay in nixos/users/allu/confs/. This file only places them and lists
;; packages. deskmeat.scm loads it and attaches both homes to the system;
;; standalone (allu only):
;;   guix time-machine -C guix/channels-lock.scm -- home reconfigure -L guix/modules guix/home.scm
(use-modules (gnu home)
             (gnu home services)
             (gnu home services desktop)
             (gnu home services dotfiles)
             (gnu home services gnupg)
             (gnu home services shepherd)
             (gnu home services sound)
             (gnu packages)
             (gnu packages libcanberra)
             (gnu packages sync)
             (gnu packages containers)
             (gnu services)
             (gnu services shepherd)
             (guix gexp)
             (guix utils)
             (allu packages))

(define niri-config
  ;; The shared niri.kdl plus the Guix-only tail. KDL allows repeated
  ;; top-level nodes, so concatenation is all the merging needed.
  (computed-file "niri-config.kdl"
                 #~(begin
                     (use-modules (ice-9 textual-ports))
                     (call-with-output-file #$output
                       (lambda (out)
                         (for-each (lambda (file)
                                     (display (call-with-input-file file
                                                get-string-all)
                                              out))
                                   '(#$(local-file "../nixos/users/allu/confs/niri.kdl")
                                     #$(local-file "niri.kdl"))))))))

(define %home-packages
  (cons* chicago95
         (specifications->packages
          '(;; niri session: bar, launcher, terminal, daemons it spawns
            "waybar" "fuzzel" "foot" "mako" "swayidle" "swaylock" "wlsunset"
            "swaybg" "polkit-gnome" "cliphist" "wl-clipboard" "libnotify"
            "pipewire" "wireplumber" "noise-suppression-for-voice" "dbus"
            ;; apps and helpers from users/allu/desktop.nix
            "imv" "zathura" "zathura-pdf-mupdf" "wtype" "chafa" "file"
            "dolphin" "ark" "kio-extras" "kdegraphics-thumbnailers"
            "ffmpegthumbs" "plasma-integration" "papirus-icon-theme" "7zip"
            "pavucontrol" "bibata-cursor-theme"
            ;; shell
            "zsh-autosuggestions" "zsh-syntax-highlighting" "fzf-tab" "fzf"
            "bat" "eza" "tmux" "rclone"))))

(define %home-services
  (list
   (service home-dotfiles-service-type
            (home-dotfiles-configuration
             (source-directory (current-source-directory))
             (directories '("dotfiles"))))
   ;; Shared with NixOS (C6): placed as-is, never forked.
   (service home-xdg-configuration-files-service-type
            `(("niri/config.kdl" ,niri-config)
              ("nvim/init.lua" ,(local-file "../nixos/users/allu/confs/init.lua"))
              ("lf/lfrc" ,(local-file "../nixos/users/allu/confs/lfrc"))
              ("waycorner/config.toml"
               ,(local-file "../nixos/users/allu/confs/waycorner.toml"))))
   (service home-files-service-type
            `((".claude/settings.json"
               ,(local-file "../nixos/users/allu/confs/claude-settings.json"))
              (".local/share/emoji-picker/emojis.txt"
               ,(local-file "../nixos/users/allu/confs/emojis.txt"))
              ;; Chime played by the niri volume keys at a fixed path.
              (".local/share/sounds/volume-change.oga"
               ,(file-append sound-theme-freedesktop
                             "/share/sounds/freedesktop/stereo/audio-volume-change.oga"))))
   (simple-service 'session-variables
                   home-environment-variables-service-type
                   `(("EDITOR" . "nvim")
                     ("VISUAL" . "nvim")
                     ("PAGER" . "less")
                     ;; ~/.cargo/bin: nirius, chameleos, waycorner (README).
                     ("PATH" . "$HOME/.local/bin:$HOME/.cargo/bin:$PATH")
                     ("XDG_DATA_DIRS"
                      . "$XDG_DATA_DIRS:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share")
                     ;; Dotfiles first in listings; Dutch formats otherwise.
                     ("LC_COLLATE" . "C")
                     ("LC_ADDRESS" . "nl_NL.UTF-8")
                     ("LC_IDENTIFICATION" . "nl_NL.UTF-8")
                     ("LC_MEASUREMENT" . "nl_NL.UTF-8")
                     ("LC_MONETARY" . "nl_NL.UTF-8")
                     ("LC_NAME" . "nl_NL.UTF-8")
                     ("LC_NUMERIC" . "nl_NL.UTF-8")
                     ("LC_PAPER" . "nl_NL.UTF-8")
                     ("LC_TELEPHONE" . "nl_NL.UTF-8")
                     ("LC_TIME" . "nl_NL.UTF-8")
                     ;; NixOS put this in Xorg's 00-keyboard.conf for niri;
                     ;; libxkbcommon reads these when niri.kdl sets no layout.
                     ("XKB_DEFAULT_LAYOUT" . "ee")
                     ("XKB_DEFAULT_VARIANT" . "us")
                     ("XCURSOR_THEME" . "Bibata-Modern-Ice")
                     ("XCURSOR_SIZE" . "16")
                     ;; kde: plasma-integration reads kdeglobals; Windows is
                     ;; qtbase's built-in Win9x style.
                     ("QT_QPA_PLATFORMTHEME" . "kde")
                     ("QT_STYLE_OVERRIDE" . "Windows")
                     ("GTK_USE_PORTAL" . "1")
                     ("ELECTRON_OZONE_PLATFORM_HINT" . "auto")
                     ;; For the rnnoise plugin in pipewire.conf.d.
                     ("LADSPA_PATH" . "$HOME/.guix-home/profile/lib/ladspa")
                     ;; Steam's sandbox sees the library on the data disk (S2).
                     ("GUIX_SANDBOX_EXTRA_SHARES" . "/mnt/data_main")))
   (service home-dbus-service-type)
   (service home-pipewire-service-type)
   (service home-gpg-agent-service-type
            (home-gpg-agent-configuration (ssh-support? #t)))))

(define jane-home
  (home-environment
   (packages %home-packages)
   (services %home-services)))

(define allu-home
  (home-environment
   (packages %home-packages)
   (services
    (cons
     ;; One-time setup, not declarable (OAuth): `rclone config` (remote
     ;; "gdrive3", type drive), `mkdir ~/Drive`, then
     ;; `rclone bisync ~/Drive gdrive3:Documents --resync`.
     (simple-service 'allu-timers home-shepherd-service-type
                     (list (shepherd-timer
                            '(rclone-drive-bisync) "*/10 * * * *"
                            #~("/bin/sh" "-c"
                               #$(file-append rclone "/bin/rclone bisync \"$HOME/Drive\" gdrive3:Documents --resilient"))
                            #:documentation "Bisync ~/Drive with Google Drive.")
                           ;; NixOS virtualisation.podman.autoPrune.
                           (shepherd-timer
                            '(podman-prune) "0 4 * * 1"
                            #~(#$(file-append podman "/bin/podman")
                               "system" "prune" "--force")
                            #:documentation "Weekly podman prune.")))
     %home-services))))

allu-home
