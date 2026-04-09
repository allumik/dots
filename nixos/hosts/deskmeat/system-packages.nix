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
    devtools rlang renv png curl openssl ssh jsonlite # httpgd
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
    fuse3 fuse-overlayfs qemu quickemu podman-tui podman-compose

    # Other Tools
    tesseract openconnect poppler poppler-utils wl-clipboard gdrive3 puddletag vial tail-tray
    pandoc quarto texlive.combined.scheme-small
    nixfmt html-tidy shellcheck-minimal isort ispell # some spell~swords~checker functionality
    typst typstyle # latex reborn
    noisetorch # noise reduction for mic
    beets # music library manager # broken in unstable
    nextflow
    gemini-cli
    dzgui

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
