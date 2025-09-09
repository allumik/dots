{ pkgs, ... }:

with pkgs;
rec {
  tacseqApp = rPackages.buildRPackage {
    name = "tacseqApp";
    # build from a local package for ease of distribution and privacy
    src = ~/Documents/Archive/tacseqApp-1.1.4.tar.gz;
    propagatedBuildInputs = with pkgs.rPackages; [
      shiny
      shinydashboard
      ggplot2
      dplyr
      tidyr
      readr
      purrr
      tibble
      stringr
      DT
      foreach
      broom
      modelr
      glue
      recipes
      heatmaply
      RColorBrewer
      embed
      nFactors
      vctrs
    ];
  };

  ## define additional packages here
  # package = rPackages.buildRPackage {name = "package"}
  # TODO: add xCell
  xCell = rPackages.buildRPackage {
    name = "xCell";
    src = pkgs.fetchFromGitHub {
      owner = "dviraran";
      repo = "xCell";
      rev = "1.3";
      sha256 = "XlYXXjKDusHPEnYi92cr2EeWsgmyCNDfBJJoRtizK70=";
    };
    propagatedBuildInputs = with pkgs.rPackages; [
      GSVA
      GSEABase
      pracma
      MASS
      digest
      curl
      quadprog
      ];
  };
}
