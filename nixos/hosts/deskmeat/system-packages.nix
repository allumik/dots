# hosts/deskmeat/system-packages.nix
{ config, lib, pkgs, ... }:

with pkgs;
let
  # https://github.com/NixOS/nixpkgs/issues/475732 for python314
  py-env = python313.withPackages(ps: with ps; [
    pip setuptools
    numpy numba pandas scipy scikit-learn
    matplotlib ipykernel euporie torchWithRocm
    west # for zmk
  ]);

  # minimal R tidyverse env, use pixi for other stuff
  r-env = rWrapper.override{ packages = with rPackages; [
    # basic dev env with parallel support
    languageserver tidyverse foreach doParallel BiocParallel openssl 
    # support for common files and libs
    quarto readxl jsonlite dotenv
  ]; };

  pkgs_list = [
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
    openconnect wl-clipboard gdrive3 pandoc quarto texlive.combined.scheme-small wakeonlan nextflow
    nixfmt nil nixd html-tidy shellcheck-minimal isort ispell # some spell~swords~checker functionality
    typst typstyle # latex reborn
    beets # music library manager
    dfu-util # for the keyboard gods
    claude-code # yes...
    

    # AMD ROCm thingies - use docker containers for more up to date support
    rocmPackages.amdsmi rocmPackages.rocm-core rocmPackages.rocm-device-libs nvtopPackages.amd

    # DEV ENV from above
    py-env r-env
  ];
in {
  ## System-wide packages and variables for this host
  # Add ROCm support for nixpkgs
  nixpkgs.config.rocmSupport = true;
  environment.systemPackages = with pkgs; pkgs_list;

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
}
