# hosts/oldlenno/configuration.nix
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
  ];
  };
in {
  ## Imports
  imports = [
    ./hardware-configuration.nix # Hardware-specific configuration
    ./users.nix
    ../base.nix # Minimal conf
    ../common.nix # Common configuration options for all hosts
  ];


  ## User accounts
  users.users.allu = {
    isNormalUser = true;
    description = "Alvin Meltsov";
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" "podman" ];
  };


  ## Networking
  networking.hostName = "oldlenno";
  networking.networkmanager = {
    enable = true;
    wifi.powersave = false; # set it to false just to be sure that it works
    ethernet.macAddress = "stable";
    plugins = with pkgs; [ networkmanager-openvpn networkmanager-openconnect ];
  };


  ## System-wide packages and variables for this host
  environment = {
    systemPackages = with pkgs; [
      # GUI Apps
      veracrypt gparted qdigidoc teams-for-linux # antigravity
      kdePackages.kcmutils kdePackages.kaccounts-providers kdePackages.kaccounts-integration
      kdePackages.flatpak-kcm kdePackages.phonon kdePackages.phonon-vlc kdePackages.kamera 
      kdePackages.kio-gdrive kdePackages.kio-fuse kdePackages.kio-extras
      # Containers
      fuse3 fuse-overlayfs qemu quickemu podman-desktop podman-tui podman-compose
      omnissa-horizon-client 

      # Other Tools
      openconnect wl-clipboard gdrive3 
      pandoc quarto texlive.combined.scheme-small
      nixfmt html-tidy shellcheck-minimal isort ispell # some spell~swords~checker functionality
      typst typstyle # latex reborn
      gemini-cli

      # DEV ENV
      py-env r-env
    ];
  };


  ## Program Settings and Services
  security.rtkit.enable = true;
  programs = {
    nix-ld.enable = true; # might make your life easier with linked library adapter
    mtr.enable = true;
    java.enable = true; # why not
    virt-manager.enable = true;
    singularity = {
      enable = true; # turn off before ChatGPT 6 is released
      enableFakeroot = true;
      package = pkgs.apptainer;
    };
  };
  services = {
    xserver.videoDrivers = [ "vmware"]; # Xorg video drivers for this host
    fstrim.enable = true; # To trim SSD blocks
    flatpak.enable = true;
    lvm.boot.thin.enable = true;
    qemuGuest.enable = true; # Enable QEMU
    spice-vdagentd.enable = true; # Necessary for the QEMU spice
    udev.packages = [ pkgs.via ]; # Set up VIA for QMK shenigans
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
