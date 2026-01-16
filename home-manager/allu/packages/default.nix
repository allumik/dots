## Why define programs as local lists and call them in the end?
# its just my preferred way of organising with regards to my priorities in programs
{ pkgs, lib, ... }:

with pkgs;
let
  prog_list = [
    ## Tools & Shells
    gh jq nextflow pixi uv dos2unix # replace conda with pixi
    pandoc texlive.combined.scheme-small typst quarto beets
    # some spell~swords~checker functionality
    nixfmt-rfc-style html-tidy shellcheck-minimal isort ispell 
    # some minuscle stuff for python/R environments
    libssh libxml2 libpng libxslt libtiff cairo  # R needs this
    # terminal bling
    zsh zsh-nix-shell zsh-fast-syntax-highlighting zsh-fzf-tab
    # googles agentic job replacer
    gemini-cli antigravity-fhs

    ## GUI
    # tools
    transmission_4-qt keepassxc puddletag gimp3-with-plugins 
    eduvpn-client code
    # "office" stuff
    libreoffice-qt zotero thunderbird teams-for-linux
    # social
    discord # spotify slack zoom-us # use flatpak instead for those
    # other 
    vial

    ## DEV ENV, defined below - use conda environments for more stuff
    py-env r-env
  ];

  # add custom packages
  python_plus = python312.override {
    self = python_plus;
    packageOverrides = callPackage ./py {}; # extra packages override
  };
  
  py-env = python_plus.withPackages(ps: with ps; [
    pip setuptools
    numpy numba pandas scipy scikit-learn # use containers for gpu torch
    matplotlib seaborn altair ipykernel notebook jupyter-cache euporie
    ## extra packages from ./py override
    gamma-launcher
  ]);

  r-env = rWrapper.override{ packages = with rPackages; [
    # some deps for other packages
    devtools rlang renv png curl openssl ssh jsonlite # httpgd
    # support for common files and libs
    languageserver tinytex pandoc rmdformats quarto feather readxl dotenv
    # basic dev env
    tidyverse patchwork foreach doParallel iterators BiocParallel
    # other stuff... use containers, or conda
  ]; };

  font_list = [
    # Nerd fonts, all-in-one package with pretty symbols
    nerd-fonts.iosevka-term
    # Other fonts
    source-code-pro hack-font liberation_ttf
    quattrocento quattrocento-sans
    merriweather merriweather-sans
  ];
in 
{
  # Programs & Services
  nixpkgs.config.allowUnfree = true;
  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
    brave = {
      enable = true;
      commandLineArgs = [ "--ozone-platform=wayland" ];
      nativeMessagingHosts = [ pkgs.kdePackages.plasma-browser-integration ];
    };
    vscode = {
      enable = true;
      package = pkgs.vscode.fhs;
    };
  };
  services = {
    syncthing = {
      enable = true;
      tray.enable = true;
    };
  };

  ## Install the list of packages from above
  home.packages = with pkgs; prog_list ++ font_list;
}
