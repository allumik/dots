{ config, lib, pkgs, ... }:

with pkgs;
let 
  # Follow https://github.com/NixOS/nixpkgs/issues/475732 for Python 3.14
  py-env = python313.withPackages(ps: with ps; [
    pip setuptools
    numpy numba pandas scipy scikit-learn # use containers for gpu torch
    matplotlib seaborn altair ipykernel euporie 
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
    veracrypt gparted qdigidoc

    # KDE stuff
    kdePackages.kcmutils kdePackages.kaccounts-providers kdePackages.kaccounts-integration
    kdePackages.flatpak-kcm kdePackages.phonon kdePackages.phonon-vlc kdePackages.kamera 
    kdePackages.kio-gdrive kdePackages.kio-fuse kdePackages.kio-extras kdePackages.kcolorchooser

    # Containers
    fuse3 fuse-overlayfs qemu quickemu podman-tui podman-compose
    omnissa-horizon-client 

    # Other Tools
    openconnect wl-clipboard gdrive3 pandoc quarto texlive.combined.scheme-small # tail-tray
    nixfmt html-tidy shellcheck-minimal isort ispell # some spell~swords~checker functionality
    typst typstyle # latex reborn
    gemini-cli

    # DEV ENV
    py-env r-env
  ];
in {
  ## System-wide packages and variables for this host
  environment.systemPackages = with pkgs; pkgs_list;

  programs = {
    nix-ld.enable = true; # might make your life easier with linked library adapter
    mtr.enable = true;
    java.enable = true; # why not
    virt-manager.enable = true;
    singularity = {
      enable = true; # turn off before ChatGPT 6 is released #2024jokes
      enableFakeroot = true;
      package = pkgs.apptainer;
    };
  };
}

