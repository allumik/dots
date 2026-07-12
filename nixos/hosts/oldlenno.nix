# hosts/oldlenno.nix
# The old laptop workhorse who is still kicking. Monolithic: hardware,
# networking, services, packages, and user wiring all live here; shared
# config is in base.nix (imported) and stylix.nix (imported, theming).
{ config, lib, pkgs, modulesPath, ... }:

let
  # Follow https://github.com/NixOS/nixpkgs/issues/475732 for Python 3.14
  py-env = pkgs.python313.withPackages (ps: with ps; [
    pip setuptools
    numpy numba pandas scipy scikit-learn # use containers for gpu torch
    matplotlib seaborn altair ipykernel euporie
  ]);
  r-env = pkgs.rWrapper.override { packages = with pkgs.rPackages; [
    # some deps for other packages
    devtools rlang renv png curl openssl ssh jsonlite # httpgd
    # support for common files and libs
    languageserver tinytex pandoc rmdformats quarto feather readxl dotenv
    # basic dev env
    tidyverse patchwork foreach doParallel iterators BiocParallel
    # other stuff... use containers, or pixi
  ]; };

  pkgs_list = with pkgs; [
    # GUI Apps
    veracrypt gparted qdigidoc

    # Containers
    fuse3 fuse-overlayfs qemu quickemu podman-tui podman-compose
    omnissa-horizon-client

    # Other Tools
    openconnect wl-clipboard gdrive3 pandoc quarto texliveSmall tail-tray
    nixfmt html-tidy shellcheck-minimal isort ispell # some spell~swords~checker functionality
    typst typstyle # latex reborn
    gemini-cli

    # DEV ENV
    py-env r-env
  ];
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix") # hardware detection helper
    ./base.nix # Shared minimal + desktop config
    ./stylix.nix # Unified GTK/Qt/fuzzel/waybar theming
  ];

  ## Nixpkgs platform
  nixpkgs.hostPlatform = "x86_64-linux";

  ## Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel modules and initrd
  # specify the kernel package - use the default for the old intel cpu
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # Intel GPU and CPU related
  boot.kernelModules = [ "kvm-intel" ];
  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "sr_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.verbose = false; # quiet initrd-stage messages so they don't clobber the tuigreet greeter
  boot.consoleLogLevel = 3; # suppress kernel INFO spam on the console tuigreet draws on

  # Filesystems and Swap
  boot.initrd.luks.devices."luks-de8b828a-b902-4b08-aa80-9786c15a0c4d".device = "/dev/disk/by-uuid/de8b828a-b902-4b08-aa80-9786c15a0c4d";
  boot.initrd.luks.devices."luks-d12d5ae9-f3e4-4913-b0ff-418d17973d24".device = "/dev/disk/by-uuid/d12d5ae9-f3e4-4913-b0ff-418d17973d24";

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/ae45eedd-75bd-4795-b2ea-21fbbb84b89a";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/EEEC-31D4";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };
  swapDevices = [ { device = "/dev/disk/by-uuid/2d83e3ce-fbfb-4be6-a504-6192f9b892e2"; } ];
  # enable zswap cache
  boot.kernelParams = [
    "zswap.enabled=1" # enables zswap
    "zswap.zpool=zsmalloc" # recommended to set
    "zswap.max_pool_percent=25" # maximum percentage of RAM that zswap is allowed to use
    "zswap.shrinker_enabled=1" # whether to shrink the pool proactively on high memory pressure
    "quiet" # also tells systemd to suppress its own unit status lines, not just the kernel
  ];

  # The additional WD green disk
  fileSystems."/mnt/data_main" = {
    device = "/dev/disk/by-uuid/e84099b2-20d2-4b41-9d8b-c3faf311c719";
    fsType = "ext4";
  };

  # Hardware Support
  hardware = {
    enableAllFirmware = true;
    graphics = {
      enable = true;
      package = pkgs.mesa;
    };
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    keyboard.qmk.enable = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  environment.systemPackages = pkgs_list;

  ## Networking
  networking.hostName = "oldlenno";
  # Trust the Tailscale interface in the firewall
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.networkmanager = {
    enable = true;
    wifi.powersave = false; # set it to false just to be sure that it works
    ethernet.macAddress = "stable";
    plugins = with pkgs; [ networkmanager-openvpn networkmanager-openconnect ];
  };

  ## Program Settings and Services
  programs = {
    niri.enable = true;
    mtr.enable = true;
    java.enable = true; # why not
    virt-manager.enable = true;
    singularity = {
      enable = true; # turn off before ChatGPT 6 is released #2024jokes
      enableFakeroot = true;
      package = pkgs.apptainer;
    };
  };

  security.rtkit.enable = true;

  services = {
    scx.enable = true; # default scx_rustland, build issue on 250914
    scx.scheduler = "scx_bpfland"; # https://wiki.cachyos.org/configuration/sched-ext/

    xserver.videoDrivers = [ "vmware" ]; # Xorg video drivers for this host
    fstrim.enable = true; # To trim SSD blocks
    flatpak.enable = true;
    lvm.boot.thin.enable = true;
    qemuGuest.enable = true; # Enable QEMU
    spice-vdagentd.enable = true; # Necessary for the QEMU spice
    udev.packages = [ pkgs.via ]; # Set up VIA for QMK shenigans
    openssh.enable = true;
    tailscale = {
      enable = true;
      extraUpFlags = [ "--ssh" ];
    };
    pcscd = {
      enable = true; # smard card reader support
      plugins = [ pkgs.ccid ];
    };
    # keep running unless shut down manually
    logind.settings.Login.extraConfig = ''
      IdleAction=ignore
      HandleLidSwitch=ignore
    '';
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
  };

  systemd = {
    # no sleep for you
    targets.sleep.enable = false;
    targets.suspend.enable = false;
    targets.hibernate.enable = false;
    targets.hybrid-sleep.enable = false;

    # NixOS otherwise injects a stripped PATH via Environment= on the niri.service
    # unit which shadows the imported user-manager PATH. Disabling the default
    # lets niri inherit the full PATH set up by niri-session.
    user.services.niri.enableDefaultPath = false;
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
  # brave/foot/syncthing/etc. are all configured in users/allu/confs/desktop.nix
  # and theme.nix - this used to also carry Plasma-specific power/lock config
  # (programs.plasma.powerdevil/kscreenlocker) from when this host ran Plasma,
  # which doesn't apply to niri and doesn't exist without plasma-manager imported.
  home-manager.users.allu = {
    imports = [ ../users/allu/home.nix ];
  };
}
