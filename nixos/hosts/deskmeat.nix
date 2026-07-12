# hosts/deskmeat.nix
# The main home workstation. Monolithic: hardware, networking, services,
# packages, and user wiring all live here; shared config is in base.nix
# (imported) and stylix.nix (imported, theming).
{ config, lib, pkgs, modulesPath, ... }:

let
  # https://github.com/NixOS/nixpkgs/issues/475732 for python314
  py-env = pkgs.python313.withPackages (ps: with ps; [
    pip setuptools
    numpy numba pandas scipy scikit-learn
    matplotlib ipykernel euporie torchWithRocm
    west # for zmk
  ]);

  # minimal R tidyverse env, use pixi for other stuff
  r-env = pkgs.rWrapper.override { packages = with pkgs.rPackages; [
    # basic dev env with parallel support
    languageserver tidyverse foreach doParallel BiocParallel openssl
    # support for common files and libs
    quarto readxl jsonlite dotenv
  ]; };

  pkgs_list = with pkgs; [
    # GUI Apps
    veracrypt gparted scarlett2 alsa-scarlett-gui qdigidoc
    digikam audacity omnissa-horizon-client calibre

    # desktop stuff
    nirius chameleos waycorner udiskie xwayland-satellite swaybg wdisplays hyprpicker fontpreview
    playerctl brightnessctl
    xdg-desktop-portal-termfilechooser

    # Gaming
    winetricks wineWow64Packages.stable wineWow64Packages.waylandFull wineWow64Packages.fonts
    lutris protonup-qt
    discord gamma-launcher

    # Containers
    fuse3 fuse-overlayfs qemu quickemu podman-tui podman-compose

    # Other Tools
    openconnect wl-clipboard gdrive3 pandoc quarto texliveSmall wakeonlan nextflow
    nixfmt nil nixd html-tidy shellcheck-minimal isort ispell # some spell~swords~checker functionality
    typst typstyle # latex reborn
    beets # music library manager
    dfu-util # for the keyboard gods
    claude-code pi-coding-agent bubblewrap nix-bubblewrap herdr # yes...

    # AMD ROCm thingies - use docker containers for more up to date support
    rocmPackages.amdsmi rocmPackages.rocm-core rocmPackages.rocm-device-libs nvtopPackages.amd

    # DEV ENV from above
    py-env r-env
  ];
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix") # hardware detection helper
    ./base.nix # Shared minimal + desktop config
    ./stylix.nix # Unified GTK/Qt/fuzzel/waybar theming
  ];

  ## Nixpkgs platform / config
  nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.config.rocmSupport = true; # Add ROCm support for nixpkgs

  ## Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.useOSProber = true;

  # Kernel modules and initrd
  boot.kernelPackages = pkgs.linuxPackages_zen; # zen's current bzImage output is broken upstream; normal might be more stable for network anyway
  boot.kernelModules = [
    # AMD GPU and CPU related, keep dm-crypt for encrypted drives
    "amdgpu" "kvm-amd" "dm-crypt"
  ];
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "uas" "usbhid" "sd_mod" ];
  boot.initrd.verbose = false; # quiet initrd-stage messages so they don't clobber the tuigreet greeter
  boot.consoleLogLevel = 3; # suppress kernel INFO spam on the console tuigreet draws on

  # Filesystems and Swap
  fileSystems."/" = { device = "/dev/disk/by-uuid/fae35e59-edc7-41b1-9d8c-8cc5bead8d11"; fsType = "ext4"; };
  fileSystems."/boot" = { device = "/dev/disk/by-uuid/D63B-498A"; fsType = "vfat"; options = [ "fmask=0022" "dmask=0022" ]; };

  # Primary SATA Storage (SD Ultra 3D)
  fileSystems."/mnt/data_main" = {
    device = "/dev/disk/by-uuid/f0b1c5e8-5227-44d3-bd01-ec7b7b655205";
    fsType = "ext4";
    options = [ "users" "nofail" "relatime" "x-gvfs-show" "exec" ];
  };

  # Secondary SATA Storage (Crucial BX500)
  fileSystems."/mnt/data_extra" = {
    device = "/dev/disk/by-uuid/00c47e7d-748e-4cf8-b6f7-0a1dd14b9fdc";
    fsType = "ext4";
    options = [ "users" "nofail" "relatime" "x-gvfs-show" "exec" ];
  };

  swapDevices = [ { device = "/dev/nvme0n1p3"; } ];
  boot.resumeDevice = "/dev/nvme0n1p3";
  boot.kernel.sysctl = { "vm.swappiness" = 10; }; # lower it from 60 as we have loads of RAM
  # Enable zramSwap only in RAM compression for large memory loads, defaults are: 50% RAM; zstd
  boot.kernelParams = [
    "zswap.enabled=1" # enables zswap
    "zswap.max_pool_percent=75" # maximum percentage of RAM that zswap is allowed to use
    "zswap.shrinker_enabled=1" # whether to shrink the pool proactively on high memory pressure
    "zswap.zpool=zsmalloc"
    "iwlwifi.disable_11ax=1"
    "iwlwifi.uapsd_disable=1" # Disable U-APSD to improve stability on some APs
    "iwlwifi.optout_pm=1"
    "iwlmvm.power_scheme=1"
    "pcie_aspm=off"
    "quiet" # also tells systemd to suppress its own unit status lines, not just the kernel
  ];

  # Hardware Support
  hardware = {
    graphics = {
      enable = true;
      package = pkgs.mesa;
      extraPackages = with pkgs; [
        rocmPackages.clr
        rocmPackages.clr.icd
      ];
    };
    amdgpu.overdrive.enable = true;
    enableAllFirmware = true;
    keyboard.qmk.enable = true; # for the planck keyboard with vial
    bluetooth = {
      enable = true;
      settings = { General = { Enable = "Source, Sink, Media, Socket"; Experimental = true; }; Policy = { AutoEnable = true; }; };
    };
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.systemPackages = pkgs_list;

  ## Networking
  networking.hostName = "deskmeat";
  # Trust the Tailscale interface in the firewall
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  # Wake-on-LAN Configuration
  networking.interfaces.enp2s0.wakeOnLan.enable = true;
  networking.firewall.allowedUDPPorts = [ 9 ];
  networking.networkmanager = {
    enable = true;
    wifi.powersave = false; # set it to false just to be sure that it works
    plugins = with pkgs; [ networkmanager-openvpn networkmanager-openconnect ];
  };

  ## Program Settings and Services
  programs = {
    niri.enable = true;
    mtr.enable = true;
    java.enable = true; # why not
    virt-manager.enable = true;
    kdeconnect.enable = true;
    steam.enable = true;
    singularity = {
      enable = true; # turn off before ChatGPT 6 is released
      enableFakeroot = true;
      package = pkgs.apptainer;
    };
  };

  security.rtkit.enable = true; # realtime scheduling for pipewire

  services = {
    scx.enable = true;
    scx.scheduler = "scx_bpfland"; # https://wiki.cachyos.org/configuration/sched-ext/

    xserver.videoDrivers = [ "amdgpu" "vmware" ]; # Xorg video drivers for this host
    fstrim.enable = true; # To trim SSD blocks
    flatpak.enable = true;
    lvm.boot.thin.enable = true;
    qemuGuest.enable = true; # Enable QEMU
    spice-vdagentd.enable = true; # Necessary for the QEMU spice
    lact.enable = true; # Manage your GPU from 25.11 onward
    tailscale = {
      enable = true;
      # extraUpFlags = [ "--ssh" ];
    };
    pcscd = {
      enable = true; # smard card reader support
      plugins = [ pkgs.ccid ];
    };
    # login manager
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd ${config.programs.niri.package}/bin/niri-session";
          user = "greeter";
        };
      };
    };
    gnome.gnome-keyring.enable = true; # secret service

    # Always-on RNNoise denoiser wrapping just the C270 webcam mic (desk
    # fan/case noise bleeds into it). Creates a "Noise Canceling Source"
    # virtual mic; pick that as the input instead of the raw webcam.
    pipewire.extraConfig.pipewire."99-webcam-denoise" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";
          args = {
            node.description = "Noise Canceling Source";
            media.name = "Noise Canceling Source";
            filter.graph = {
              nodes = [
                {
                  type = "ladspa";
                  name = "rnnoise";
                  plugin = "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
                  label = "noise_suppressor_mono";
                  control."VAD Threshold (%)" = 50.0;
                }
              ];
            };
            capture.props = {
              node.name = "capture.webcam_denoise";
              node.passive = true;
              target.object = "alsa_input.usb-046d_C270_HD_WEBCAM_200901010001-02.mono-fallback";
            };
            playback.props = {
              node.name = "rnnoise_source";
              media.class = "Audio/Source";
            };
          };
        }
      ];
    };
  };

  systemd = {
    # NixOS otherwise injects a stripped PATH via Environment= on the niri.service
    # unit which shadows the imported user-manager PATH. Disabling the default
    # lets niri inherit the full PATH set up by niri-session.
    user.services.niri.enableDefaultPath = false;

    # `tailscale set` writes to tailscaled.state (not Nix-managed), so it
    # wouldn't survive a reinstall. Reapply on every boot instead.
    services.tailscale-accept-dns-off = {
      description = "Disable Tailscale MagicDNS override";
      after = [ "tailscaled.service" ];
      wants = [ "tailscaled.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      script = "${pkgs.tailscale}/bin/tailscale set --accept-dns=false";
    };
  };

  virtualisation = {
    containers.enable = true;
    oci-containers.backend = "podman";
    podman = {
      enable = true;
      autoPrune.enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true; # Enable USB devices connecting to QEMU spice
    vmware.guest.enable = true;
  };

  ## User accounts
  users.users.allu = {
    isNormalUser = true; # dunno man
    description = "Alvin Meltsov";
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" "podman" ];
  };
  home-manager.users = {
    # Add other users here

    # brave/foot/syncthing/tailscale-systray etc. are all configured in
    # users/allu/confs/desktop.nix and theme.nix - this used to also carry
    # Plasma-specific power/lock config (programs.plasma.powerdevil/
    # kscreenlocker) from when this host ran Plasma, which doesn't apply to
    # niri and doesn't exist without plasma-manager imported.
    allu = {
      imports = [ ../users/allu/home.nix ];

      # Two-way sync of ~/Drive with a "Drive" folder on Google Drive.
      # One-time manual setup after switching (not declarable - OAuth):
      #   rclone config          # create a remote named "gdrive", type drive
      #   rclone bisync ~/Drive gdrive:Drive --resync   # establish baseline
      # After that the timer below keeps them in sync unattended.
      home.packages = [ pkgs.rclone ];
      home.file."Drive/.keep".text = "";

      systemd.user.services.rclone-drive-bisync = {
        Unit.Description = "Bisync ~/Drive with Google Drive";
        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.rclone}/bin/rclone bisync %h/Drive gdrive:Drive/Documents --resilient";
        };
      };

      systemd.user.timers.rclone-drive-bisync = {
        Unit.Description = "Periodic Google Drive bisync";
        Timer = {
          OnBootSec = "5m";
          OnUnitActiveSec = "10m";
        };
        Install.WantedBy = [ "timers.target" ];
      };
    };
  };
}
