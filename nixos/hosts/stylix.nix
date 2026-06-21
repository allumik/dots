# hosts/stylix.nix
{ pkgs, ... }:

{
  stylix.enable = true;
  stylix.polarity = "light";
  stylix.icons = {
    enable = true;
    package = pkgs.papirus-icon-theme;
    light = "Papirus-Light";
    dark = "Papirus-Dark";
  };

  # https://tinted-theming.github.io/tinted-gallery
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/humanoid-light.yaml";
	# base16-schemes: brushtrees atelier-forest-light solarized-light silk-light
	# base24-schemes: alucard builtin-solarized-light
  stylix.fonts = {
    monospace = {
      package = pkgs.aporetic;
      name = "Aporetic Serif Mono";
    };
    # sansSerif = {
    #   package = pkgs.ibm-plex;
    #   name = "IBM Plex Sans";
    # };
  };
  stylix.fonts.sizes = {
    terminal = 10;
    applications = 10;
    popups = 10;
  };
}
