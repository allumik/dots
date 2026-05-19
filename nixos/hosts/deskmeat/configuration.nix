# hosts/deskmeat/configuration.nix
{ config, lib, pkgs, inputs, ... }:

with pkgs;
let 
  # https://github.com/NixOS/nixpkgs/issues/475732 for python314
  py-env = python313.withPackages(ps: with ps; [
    pip setuptools
    numpy numba pandas scipy scikit-learn # use containers for gpu torch
    matplotlib seaborn altair ipykernel euporie 
    torchWithRocm
  ]);

  r-env = rWrapper.override{ packages = with rPackages; [
    # some deps for other packages
    devtools rlang renv png curl openssl ssh jsonlite httpgd
    # support for common files and libs
    languageserver tinytex pandoc rmdformats quarto feather readxl dotenv
    # basic dev env
    tidyverse patchwork foreach doParallel iterators BiocParallel
    # other stuff... use containers, or pixi
  ]; };

  pkgs_list = [
    # GUI Apps
    veracrypt gparted scarlett2 alsa-scarlett-gui qdigidoc
    digikam audacity polychromatic omnissa-horizon-client calibre

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
    tesseract openconnect poppler poppler-utils wl-clipboard gdrive3 puddletag vial
    pandoc quarto texlive.combined.scheme-small wakeonlan
    nixfmt html-tidy shellcheck-minimal isort ispell # some spell~swords~checker functionality
    typst typstyle # latex reborn
    noisetorch # noise reduction for mic
    beets # music library manager # broken in unstable
    nextflow
    gemini-cli

    # AMD ROCm thingies - use docker containers for more up to date support
    rocmPackages.amdsmi rocmPackages.rocm-core rocmPackages.rocm-device-libs nvtopPackages.amd

    # DEV ENV from above
    py-env r-env
  ];
in {
  ## Imports
  imports = [
    ../base.nix # Minimal conf
    ../common.nix # Common configuration options for all hosts
    ./hardware-configuration.nix # Hardware-specific configuration
    ./users.nix
  ];


  ## System-wide packages and variables for this host
  # Add ROCm support for nixpkgs
  nixpkgs.config.rocmSupport = true;
  environment.systemPackages = with pkgs; pkgs_list;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";


  ## Networking
  networking.hostName = "deskmeat";
  # Trust the Tailscale interface in the firewall
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  # Wake-on-LAN Configuration
  # Replace "enp3s0" with your actual ethernet interface name (find it using 'ip a')
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
    steam.enable = true;
    singularity = {
      enable = true; # turn off before ChatGPT 6 is released
      enableFakeroot = true;
      package = pkgs.apptainer;
    };
  };

  services = {
    xserver.videoDrivers = [ "amdgpu" "vmware"]; # Xorg video drivers for this host
    lvm.boot.thin.enable = true;
    qemuGuest.enable = true; # Enable QEMU
    spice-vdagentd.enable = true; # Necessary for the QEMU spice
    udev.packages = [ pkgs.via ]; # Set up VIA for QMK shenigans
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
  };

  # NixOS otherwise injects a stripped PATH via Environment= on the niri.service
  # unit which shadows the imported user-manager PATH. Disabling the default
  # lets niri inherit the full PATH set up by niri-session.
  systemd.user.services.niri.enableDefaultPath = false;

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
}
