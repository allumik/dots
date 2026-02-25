# hosts/deskmeat/configuration.nix
{ config, lib, pkgs, ... }:

let 
  py-env = pkgs.python314.withPackages(ps: with ps; [
    pip setuptools
    numpy numba pandas scipy scikit-learn # use containers for gpu torch
    matplotlib seaborn altair # ipykernel euporie # https://github.com/NixOS/nixpkgs/issues/493614
  ]);

  r-env = pkgs.rWrapper.override{ packages = with pkgs.rPackages; [
    # some deps for other packages
    devtools rlang renv png curl openssl ssh jsonlite # httpgd
    # support for common files and libs
    languageserver tinytex pandoc rmdformats quarto feather readxl dotenv
    # basic dev env
    tidyverse patchwork foreach doParallel iterators BiocParallel
    # other stuff... use containers, or pixi
  ]; };
in {
  ## Imports
  imports = [
    ./hardware-configuration.nix # Hardware-specific configuration
    ./users.nix
    ../base.nix # Minimal conf
    ../common.nix # Common configuration options for all hosts
  ];


  ## Networking
  networking.hostName = "deskmeat";
  networking.networkmanager = {
    enable = true;
    wifi.powersave = false; # set it to false just to be sure that it works
    plugins = with pkgs; [ networkmanager-openvpn networkmanager-openconnect ];
  };


  ## System-wide packages and variables for this host
  # Add ROCm support for nixpkgs
  nixpkgs.config.rocmSupport = true;
  environment = {
    systemPackages = with pkgs; [
      # GUI Apps
      veracrypt gparted scarlett2 alsa-scarlett-gui qdigidoc
      digikam audacity polychromatic omnissa-horizon-client # calibre # broken in unstable
      teams-for-linux

      # KDE account management & other stuff
      kdePackages.flatpak-kcm kdePackages.phonon kdePackages.phonon-vlc kdePackages.kamera 
      kdePackages.kcolorpicker

      kdePackages.kio-gdrive kdePackages.kio-fuse kdePackages.kio-extras kdePackages.libkgapi 
      kdePackages.kaccounts-providers kdePackages.kaccounts-integration

      # Gaming
      winetricks wineWow64Packages.stable wineWow64Packages.waylandFull wineWow64Packages.fonts
      lutris protonup-qt
      discord gamma-launcher

      # Containers
      fuse3 fuse-overlayfs qemu quickemu podman-desktop podman-tui podman-compose

      # Other Tools
      tesseract openconnect poppler poppler-utils wl-clipboard gdrive3 puddletag vial 
      pandoc quarto texlive.combined.scheme-small
      nixfmt html-tidy shellcheck-minimal isort ispell # some spell~swords~checker functionality
      typst typstyle # latex reborn
      noisetorch # noise reduction for mic
      # beets # music library manager # broken in unstable
      nextflow
      gemini-cli

      # AMD ROCm thingies - use docker containers for more up to date support
      rocmPackages.amdsmi rocmPackages.rocm-core nvtopPackages.amd

      # DEV ENV from above
      py-env r-env
    ];
  };

  ## Program Settings and Services
  security.rtkit.enable = true;
  programs = {
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
  services = {
    xserver.videoDrivers = [ "amdgpu" "vmware"]; # Xorg video drivers for this host
    fstrim.enable = true; # To trim SSD blocks
    flatpak.enable = true;
    lvm.boot.thin.enable = true;
    udisks2.enable = true; # might help with calibre usb connection
    qemuGuest.enable = true; # Enable QEMU
    spice-vdagentd.enable = true; # Necessary for the QEMU spice
    udev.packages = [ pkgs.via ]; # Set up VIA for QMK shenigans
    lact.enable = true; # Manage your GPU from 25.11 onward
    pcscd = {
      enable = true; # smard card reader support
      plugins = [ pkgs.ccid ];
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
}
