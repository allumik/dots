# hosts/stylix.nix
{ pkgs, ... }:

{
  stylix.enable = true;
  stylix.polarity = "light";
  # Chicago95: the Win95 icon set, closest packaged stand-in for the Memphis98
  # theme the old Plasma config used. Single variant, so light == dark.
  # ponytail: its index.theme has no Inherits=, so icon names it lacks fall
  # through to hicolor only and show up blank. If that bites, wrap it in an
  # overlay that appends `Inherits=Papirus-Light` to index.theme.
  stylix.icons = {
    enable = true;
    package = pkgs.chicago95;
    light = "Chicago95";
    dark = "Chicago95";
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
