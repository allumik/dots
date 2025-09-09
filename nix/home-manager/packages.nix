{ pkgs, lib, ... }:

with pkgs;
let

  # quartoRenvForCustom = rWrapper.override {
  #   packages = [ rPackages.rmarkdown ];
  # };
  # # 'python312' is assumed to be your specific Python environment (e.g., pkgs.python312)
  # quartoPythonEnvForCustom = python312.withPackages (ps: with ps;
  #   [ jupyter ipython ]
  # );
  #
  # --- Define your custom Quarto package with an overridden preFixup phase ---
  # quarto_custom = quarto.overrideAttrs (oldAttrs: {
  #   # Now, replace the preFixup script.
  #   preFixup = ''
  #     wrapProgram $out/bin/quarto \
  #       --set-default QUARTO_DENO ${lib.getExe deno} \
  #       --set-default QUARTO_PANDOC ${lib.getExe pandoc} \
  #       --set-default QUARTO_ESBUILD ${lib.getExe esbuild} \
  #       --set-default QUARTO_DART_SASS ${lib.getExe dart-sass} \
  #       --set-default QUARTO_TYPST ${lib.getExe typst} \
  #       ${lib.optionalString (rWrapper != null) "--set-default QUARTO_R ${quartoRenvForCustom}/bin/R"} \
  #       ${lib.optionalString (python312 != null) "--set-default QUARTO_PYTHON ${quartoPythonEnvForCustom}/bin/python3"}
  #   '';
  # });

  prog_list = [
    # dev environments - replace with conda envs
    py-env
    r-env

    ## GUI apps
    transmission_4-qt
    alacritty
    keepassxc
    syncthing
    zotero
    libreoffice-qt
    beets # music metadata editor
    thunderbird
    gimp3-with-plugins
    audacity
    teams-for-linux
    eduvpn-client
    discord
    puddletag
    calibre
    qgis
    # spotify # use flatpak instead
    # slack # use flatpak instead
    # zoom-us # use flatpak instead, screensharing issue

    ## dev env TODO: split it to development environments
    helix
    gh
    jq
    fd
    gdrive3
    nodejs # node is sadly a dependency for some packages...
    nodePackages.npm
    nodePackages.yarn
    pandoc
    texlive.combined.scheme-small
    # quarto_custom
    quarto

    nextflow
    # some spell~swords~checker functionality
    html-tidy
    shellcheck-minimal
    isort
    ispell
    nixfmt-rfc-style

    ## some minuscle stuff for environments
    libssh      # R needs this
    libxml2     # R needs this
    libpng      # R needs this
    libxslt     # R needs this
    libtiff     # R needs this
    cairo       # R needs this

    ## terminal blingness
    zsh # enabled in config
    zsh-nix-shell
    zsh-fast-syntax-highlighting
    zsh-fzf-tab
  ];


  # add custom packages
  python_plus = python312.override {
    self = python_plus;
    packageOverrides = callPackage ./packages/py {};
  };
  
  py-env = python_plus.withPackages(ps: with ps; [
    pip
    notebook
    jupyter-cache
    numpy
    pandas
    matplotlib
    seaborn
    altair
    scipy
    scikit-learn
    python-dotenv
    setuptools
    torchWithCuda # use this one so that hopefully the conda env picks up the system torch
    jaxlib
    # after declaring them in packages/py/, add them here is
    # going to manually add these packages requires great
    # strength of spirit and legendary resilience.
    gamma-launcher
  ]);

  r-env = rWrapper.override{ packages = with rPackages; [
    # some deps for other packages
    devtools rlang renv png curl openssl ssh httpgd jsonlite
    # support for common files and libs
    languageserver tinytex pandoc rmarkdown quarto feather

    # basic dev env
    tidyverse
    rmdformats
    bookdown
    tidymodels
    recipes
    patchwork
    foreach
    doParallel
    iterators
    readxl
    rtracklayer
    dotenv

    # bioconductor stuff - maybe offload to a conda env?
    sva
    limma
    DESeq2
    edgeR
    GenomicRanges
    biomaRt
		BiocParallel
		S4Vectors

    ] ++ [
    # Additional packages - again, just make micromamba envs
    (import ./packages/r pkgs).tacseqApp

    # other stuff... use containers
  ]; };

in {
  ## List of packages from above
  programs = with pkgs; prog_list;


  ## FONTS
  fonts = with pkgs; [
    iosevka # Find your poison at: https://typeof.net/Iosevka/customizer

    (iosevka.override {
      privateBuildPlan = {
        family = "Iosevka Term SS08";
        spacing = "term";
        serifs = "sans";
        # no-cv-ss = true;

        variants = {
          inherits = "ss08";
        };
      };

      set = "iosevka-term-ss08";
    })

    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.iosevka
    nerd-fonts.agave
    nerd-fonts.victor-mono

    unifont
    corefonts
    vistafonts
    ibm-plex
    noto-fonts
    liberation_ttf
    quattrocento
    quattrocento-sans
    merriweather
    merriweather-sans

    source-code-pro
    hack-font
    font-awesome
    material-icons
    powerline-symbols
  ];
}
