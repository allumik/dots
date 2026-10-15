;; deskmeat, the home workstation (AMD CPU and GPU), on Guix System.
;; Counterpart of nixos/hosts/{base,desktop,deskmeat}.nix + users/jane.nix;
;; see README.md for what was dropped and the commands to build it.
(use-modules (gnu)
             (gnu packages)
             (gnu services shepherd)
             (gnu system accounts)
             (gnu system locale)
             (gnu system pam)
             (gnu system privilege)
             (nongnu packages linux)
             (nongnu system linux-initrd)
             (allu packages))
(use-service-modules containers desktop docker guix linux networking sound
                     security-token ssh sysctl virtualization xorg)
(use-package-modules firmware games gnome hardware linux networking shells)

(load "home.scm")                       ;allu-home, jane-home

(define tuigreet-niri
  ;; greetd-user-session sets XDG_RUNTIME_DIR and XDG_SESSION_TYPE, which
  ;; nothing else does under greetd; niri --session sets XDG_CURRENT_DESKTOP
  ;; and imports the environment into D-Bus activation.
  (program-file "tuigreet-niri"
                #~(execl #$(file-append (specification->package "tuigreet")
                                        "/bin/tuigreet")
                         "tuigreet" "--time" "--cmd"
                         #$(greetd-user-session
                            (command (file-append (specification->package "niri")
                                                  "/bin/niri"))
                            (command-args '("--session"))
                            (xdg-session-type "wayland")))))

(define jane-secrets
  ;; Credential stores wiped when her session closes and again at boot (for
  ;; sessions that ended in a power cut). ponytail: allowlist, extend it
  ;; when an app stashing tokens elsewhere turns up.
  '(".local/share/keyrings" ".ssh" ".gnupg" ".config/BraveSoftware"
    ".var/app/com.brave.Browser"))

(define wipe-jane
  (program-file "wipe-jane-secrets"
                (with-imported-modules '((guix build utils))
                  #~(begin
                      (use-modules (guix build utils))
                      (for-each (lambda (dir)
                                  (delete-file-recursively
                                   (string-append "/home/jane/" dir)))
                                '#$jane-secrets)))))

(define (oneshot name requirement command doc)
  (shepherd-service
   (provision (list name))
   (requirement requirement)
   (one-shot? #t)
   (documentation doc)
   (start #~(lambda _ (zero? (apply system* '#$command))))))

(operating-system
  (host-name "deskmeat")
  (timezone "Europe/Amsterdam")
  (locale "en_US.utf8")
  (locale-definitions
   (cons (locale-definition (name "nl_NL.utf8") (source "nl_NL"))
         %default-locale-definitions))
  (keyboard-layout (keyboard-layout "ee" "us"))

  ;; D2, D10: nonguix kernel, firmware and microcode. LTS for fewer local
  ;; kernel builds when the nonguix substitutes lag; zen does not exist here.
  (kernel linux-lts)
  (firmware (list linux-firmware))
  (initrd (lambda (file-systems . rest)
            (apply microcode-initrd file-systems
                   #:microcode-packages (list amd-microcode)
                   rest)))
  (kernel-arguments
   (append '("zswap.enabled=1" "zswap.max_pool_percent=75"
             "zswap.shrinker_enabled=1" "zswap.zpool=zsmalloc"
             "iwlwifi.disable_11ax=1" "iwlwifi.uapsd_disable=1"
             "iwlwifi.optout_pm=1" "iwlmvm.power_scheme=1" "pcie_aspm=off"
             "amdgpu.ppfeaturemask=0xffffffff" ;hardware.amdgpu.overdrive
             "resume=/dev/nvme0n1p3"
             "loglevel=3")              ;quiet console under tuigreet ("quiet" is a default)
           %default-kernel-arguments))

  (bootloader
   (bootloader-configuration
    (bootloader grub-efi-bootloader)
    (targets '("/boot/efi"))
    (keyboard-layout keyboard-layout)
    ;; D1: NixOS stays bootable; its systemd-boot lives on the shared ESP.
    (menu-entries
     (list (menu-entry
            (label "NixOS")
            (device (uuid "D63B-498A" 'fat))
            (chain-loader "/EFI/systemd/systemd-bootx64.efi"))))))

  (file-systems
   (cons* (file-system
            ;; New partition for Guix (D1); label it at install time with
            ;; `e2label /dev/nvme0n1pX guix-root`.
            (device (file-system-label "guix-root"))
            (mount-point "/")
            (type "ext4"))
          (file-system
            (device (uuid "D63B-498A" 'fat))
            (mount-point "/boot/efi")
            (type "vfat"))
          ;; Primary SATA storage (SD Ultra 3D)
          (file-system
            (device (uuid "f0b1c5e8-5227-44d3-bd01-ec7b7b655205"))
            (mount-point "/mnt/data_main")
            (type "ext4")
            (mount-may-fail? #t)
            (create-mount-point? #t))
          ;; Secondary SATA storage (Crucial BX500)
          (file-system
            (device (uuid "00c47e7d-748e-4cf8-b6f7-0a1dd14b9fdc"))
            (mount-point "/mnt/data_extra")
            (type "ext4")
            (mount-may-fail? #t)
            (create-mount-point? #t))
          %base-file-systems))
  (swap-devices (list (swap-space (target "/dev/nvme0n1p3"))))

  ;; /dev/kfd and /dev/dri/renderD* belong to "render", which Guix does not
  ;; create by default; podman ROCm containers need it (R4).
  (groups (cons (user-group (name "render") (system? #t)) %base-groups))
  (users (cons* (user-account
                 (name "allu")
                 (comment "Alvin Meltsov")
                 (group "users")
                 (shell (file-append zsh "/bin/zsh"))
                 ;; input: Steam controllers; cgroup: rootless podman
                 (supplementary-groups '("wheel" "netdev" "audio" "video"
                                         "render" "input" "kvm" "libvirt"
                                         "cgroup")))
                ;; Locked until `sudo passwd jane` (no password in this repo).
                (user-account
                 (name "jane")
                 (comment "Jane")
                 (group "users")
                 (shell (file-append zsh "/bin/zsh"))
                 (supplementary-groups '("netdev" "audio" "video")))
                %base-user-accounts))

  ;; programs.mtr: mtr-packet needs raw sockets for non-root mtr.
  (privileged-programs
   (cons (privileged-program
          (program (file-append mtr "/sbin/mtr-packet"))
          (capabilities "cap_net_raw+ep"))
         %default-privileged-programs))

  (packages
   (append
    (list claude-code tailscale)
    (specifications->packages
     '(;; core tools (hosts/base.nix)
       "neovim" "tree" "fzf" "fd" "lf" "ripgrep" "wget" "lz4" "zip" "unzip"
       "7zip" "difftastic" "moreutils" "bind:utils" "pciutils"
       "v4l-utils" "ethtool" "fwupd" "ntfs-3g" "libsixel" "jq" "dos2unix"
       "parted" "usbutils" "node" "parallel" "pigz" "unrar" "git"
       "github-cli" "miller" "s-tui" "stress" "htop" "uv"
       ;; desktop layer (hosts/desktop.nix)
       "hd-idle" "foot" "vlc" "ffmpeg" "fdupes" "exfatprogs" "xhost"
       "transmission:gui" "keepassxc" "gimp" "openvpn" "libreoffice"
       "zotero" "icedove" "flatpak" "xdg-desktop-portal"
       "xdg-desktop-portal-gtk" "xdg-desktop-portal-gnome"
       "xdg-desktop-portal-kde"
       ;; fonts; corefonts come from nonguix, Vista fonts are gone
       "font-gnu-unifont" "font-microsoft-web-core-fonts" "font-google-noto"
       "font-google-noto-emoji" "font-liberation" "font-dejavu"
       "font-awesome" "font-google-material-design-icons" "font-aporetic"
       "font-ibm-plex" "font-hack" "font-adobe-source-code-pro"
       ;; deskmeat: GUI apps, niri helpers, games, containers, tools
       "gparted" "alsa-scarlett-gui" "digikam" "audacity" "calibre"
       "niri" "xwayland-satellite" "udiskie" "swaybg" "wdisplays"
       "hyprpicker" "playerctl" "brightnessctl" "blueman"
       "steam" "protonup" "wine64" "winetricks"
       "fuse" "fuse-overlayfs" "podman" "podman-compose" "singularity"
       "virt-manager" "kdeconnect" "mtr"
       "openconnect" "wl-clipboard" "pandoc" "texlive-scheme-small" "wol"
       "tidy-html" "shellcheck" "python-isort" "ispell" "typst" "typstyle"
       "beets" "dfu-util" "bubblewrap" "rocminfo"
       ;; dev envs: R stays here (O5); Python mostly lives in pixi/uv
       "python" "python-pip" "python-setuptools" "python-numpy"
       "python-numba" "python-pandas" "python-scipy" "python-scikit-learn"
       "python-matplotlib" "python-ipykernel"
       "r" "r-languageserver" "r-tidyverse" "r-foreach" "r-doparallel"
       "r-biocparallel" "r-openssl" "r-quarto" "r-readxl" "r-jsonlite"))
    %base-packages))

  (services
   (cons*
    (service greetd-service-type
             (greetd-configuration
              (terminals
               (list (greetd-terminal-configuration
                      (terminal-switch #t)
                      (default-session-command tuigreet-niri))))))
    ;; PAM entry for swaylock, which it needs to check the password.
    (service screen-locker-service-type
             (screen-locker-configuration
              (name "swaylock")
              (program (file-append (specification->package "swaylock")
                                    "/bin/swaylock"))
              (using-pam? #t)
              (using-setuid? #f)))
    (service gnome-keyring-service-type
             (gnome-keyring-configuration
              (pam-services '(("greetd" . login) ("passwd" . passwd)))))
    (service openssh-service-type
             (openssh-configuration
              (password-authentication? #f)
              (x11-forwarding? #t)))
    (service nftables-service-type
             (nftables-configuration (ruleset (local-file "nftables.conf"))))
    (service bluetooth-service-type
             (bluetooth-configuration
              (auto-enable? #t)
              (experimental #t)))
    (service rootless-podman-service-type
             (rootless-podman-configuration
              (subgids (list (subid-range (name "allu"))))
              (subuids (list (subid-range (name "allu"))))))
    (service libvirt-service-type
             (libvirt-configuration (unix-sock-group "libvirt")))
    (service virtlog-service-type)
    (service singularity-service-type)
    (service pcscd-service-type)
    (service fstrim-service-type)
    (udev-rules-service 'steam-devices steam-devices-udev-rules)
    (udev-rules-service 'qmk qmk-udev-rules) ;the planck keyboard, via vial
    (service guix-home-service-type
             `(("allu" ,allu-home) ("jane" ,jane-home)))

    (simple-service
     'deskmeat-shepherd shepherd-root-service-type
     (list
      (shepherd-service
       (provision '(tailscaled))
       (requirement '(networking))
       (documentation "Tailscale daemon.")
       (start #~(make-forkexec-constructor
                 (list #$(file-append tailscale "/bin/tailscaled")
                       "--state=/var/lib/tailscale/tailscaled.state"
                       "--socket=/var/run/tailscale/tailscaled.sock")
                 ;; netfilter and route tools tailscaled shells out to
                 #:environment-variables
                 (list (string-append "PATH=" #$iptables "/sbin:"
                                      #$iproute "/sbin"))
                 #:log-file "/var/log/tailscaled.log"))
       (stop #~(make-kill-destructor)))
      ;; `tailscale set` lands in tailscaled.state, not in this config, so
      ;; reapply it on every boot.
      (oneshot 'tailscale-accept-dns-off '(tailscaled)
               #~(#$(file-append tailscale "/bin/tailscale")
                  "set" "--accept-dns=false")
               "Keep Tailscale from overriding DNS.")
      (oneshot 'wake-on-lan '(networking)
               #~(#$(file-append ethtool "/sbin/ethtool")
                  "-s" "enp2s0" "wol" "g")
               "Arm wake-on-LAN on enp2s0.")
      (oneshot 'wipe-jane-secrets '(file-systems)
               #~(#$wipe-jane)
               "Boot-time wipe of jane's credential stores.")
      (shepherd-service
       (provision '(hd-idle))
       (requirement '(udev))
       (documentation "Spin down HDDs after 5 minutes.")
       (start #~(make-forkexec-constructor
                 (list #$(file-append hd-idle "/bin/hd-idle") "-i" "300")))
       (stop #~(make-kill-destructor)))
      (shepherd-timer '(guix-gc) "0 3 * * *"
                      #~("/run/current-system/profile/bin/guix"
                         "gc" "--delete-generations=7d")
                      #:documentation "Daily store GC (nix.gc).")))

    ;; jane's wipe when her session closes: pam_exec runs it as root.
    (simple-service
     'wipe-jane-on-logout pam-root-service-type
     (list (pam-extension
            (transformer
             (lambda (pam)
               (if (member (pam-service-name pam) '("greetd" "login"))
                   (pam-service
                    (inherit pam)
                    (session
                     (append (pam-service-session pam)
                             (list (pam-entry
                                    (control "optional")
                                    (module "pam_exec.so")
                                    (arguments
                                     (list "type=close_session" "quiet"
                                           (program-file
                                            "wipe-jane-on-logout"
                                            #~(when (equal? (getenv "PAM_USER")
                                                            "jane")
                                                (execl #$wipe-jane
                                                       "wipe-jane-secrets"))))))))))
                   pam))))))

    (modify-services %desktop-services
      (delete gdm-service-type)
      ;; pipewire-pulse (Guix Home) is the pulse server.
      (delete pulseaudio-service-type)
      (network-manager-service-type
       config => (network-manager-configuration
                  (inherit config)
                  (vpn-plugins (list network-manager-openvpn
                                     network-manager-openconnect))
                  (extra-configuration-files
                   `(("wifi-powersave.conf"
                      ,(plain-file "wifi-powersave.conf"
                                   "[connection]\nwifi.powersave=2\n"))))))
      (sysctl-service-type
       config => (sysctl-configuration
                  (inherit config)
                  (settings (cons '("vm.swappiness" . "10")
                                  (sysctl-configuration-settings config)))))
      ;; D2: substitutes for the nonguix kernel, firmware and steam.
      (guix-service-type
       config => (guix-configuration
                  (inherit config)
                  (substitute-urls
                   (cons "https://substitutes.nonguix.org"
                         %default-substitute-urls))
                  (authorized-keys
                   (cons (plain-file "nonguix.pub" "(public-key (ecc (curve Ed25519) (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))")
                         %default-authorized-guix-keys))))))))
