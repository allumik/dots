## Why define programs as local lists and call them in the end?
# its just my preferred way of organising with regards to my priorities in programs
{ pkgs, lib, ... }:

with pkgs;
let
  prog_list = [
    ## Tools & Shells
    gh jq fd gdrive3 nextflow conda uv
    pandoc texlive.combined.scheme-small quarto
    # some spell~swords~checker functionality
    nixfmt-rfc-style html-tidy shellcheck-minimal isort ispell 
    # some minuscle stuff for environments
    libssh libxml2 libpng libxslt libtiff cairo  # R needs this
    # terminal blingness
    zsh zsh-nix-shell zsh-fast-syntax-highlighting zsh-fzf-tab

    ## DEV ENV, defined below - use conda environments for more stuff
    py-env r-env

    ## GUI
    # tools
    transmission_4-qt keepassxc syncthing beets puddletag gimp3-with-plugins audacity eduvpn-client qgis
    # "office" stuff
    libreoffice-qt zotero thunderbird teams-for-linux calibre
    # social
    discord # spotify slack zoom-us # use flatpak instead for those
    # other
    polychromatic obs-studio vial
  ];

  # add custom packages
  python_plus = python312.override {
    self = python_plus;
    packageOverrides = callPackage ./py {}; # extra packages override
  };
  
  py-env = python_plus.withPackages(ps: with ps; [
    pip setuptools
    numpy numba pandas scipy scikit-learn torchWithRocm jaxlib
    matplotlib seaborn altair notebook jupyter-cache
    python-dotenv tqdm anndata
    ## extra packages from ./py override
    gamma-launcher
  ]);

  r-env = rWrapper.override{ packages = with rPackages; [
    # some deps for other packages
    devtools rlang renv png curl openssl ssh jsonlite # httpgd
    # support for common files and libs
    languageserver tinytex pandoc rmdformats quarto feather readxl dotenv
    # basic dev env
    tidyverse tidymodels recipes patchwork foreach doParallel iterators BiocParallel
    # other stuff... use containers, or conda
  ]; };

  fonts_list = [
    # Nerd fonts, all-in-one package with pretty symbols
    nerd-fonts.iosevka-term nerd-fonts.agave
    # Other fonts
    source-code-pro hack-font liberation_ttf
    quattrocento quattrocento-sans
    merriweather merriweather-sans
  ];
in 
{
  ## List of packages from above
  programs = with pkgs; prog_list;
  ## FONTS
  fonts = with pkgs; fonts_list;
}
