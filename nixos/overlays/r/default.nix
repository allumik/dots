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
}
