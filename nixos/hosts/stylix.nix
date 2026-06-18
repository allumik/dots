# hosts/stylix.nix
# Static theming baseline, shared by every host: cursor/Qt/icon defaults,
# foot's terminal palette, bat's syntax theme.
#
# Color identity: Modus Vivendi (Protesilaos Stavrou's dark Emacs theme,
# https://protesilaos.com/emacs/modus-themes-colors) is used as the fixed
# build-time scheme here. The day/night-switchable surfaces (fuzzel, waybar,
# wallpaper, GTK apps) are handled separately and live in
# users/allu/confs/theme.nix using both Modus Operandi (light) and Modus
# Vivendi (dark) - see that file for the runtime switching mechanism and
# why fuzzel/waybar/gtk are excluded from Stylix's management below.
{ pkgs, ... }:

{
  stylix.enable = true;
  stylix.polarity = "dark";
  stylix.icons = {
    enable = true;
    package = pkgs.papirus-icon-theme;
    light = "Papirus-Light";
    dark = "Papirus-Dark";
  };

  # fuzzel/waybar/gtk targets are disabled in users/allu/confs/theme.nix
  # (they're home-manager-only options, not exposed at this NixOS level) so
  # they can be swapped at runtime between Modus Operandi and Modus Vivendi -
  # Stylix only bakes in one fixed scheme at build time, so it can't drive a
  # live day/night toggle.

  # Keep the fonts already chosen in users/allu/confs/desktop.nix and
  # shell.nix as the system-wide defaults, so Stylix's own font defaults
  # don't fight with them.
  stylix.fonts = {
    monospace = {
      package = pkgs.aporetic;
      name = "Aporetic Serif Mono";
    };
    sansSerif = {
      package = pkgs.ibm-plex;
      name = "IBM Plex Sans";
    };
  };
  stylix.fonts.sizes = {
    terminal = 10;
    applications = 10;
    popups = 10;
  };

  # Modus Vivendi palette (dark). Used for foot's terminal colors, bat's
  # syntax theme, Qt apps, and cursor/icon defaults - none of these are
  # part of the live day/night swap (see theme.nix).
  stylix.base16Scheme = {
    scheme = "modus-vivendi";
    author = "Protesilaos Stavrou";
    base00 = "000000"; # bg-main
    base01 = "1e1e1e"; # bg-dim
    base02 = "5a5a5a"; # region/selection
    base03 = "646464"; # border / comments
    base04 = "989898"; # secondary fg
    base05 = "ffffff"; # fg-main
    base06 = "ffffff"; # bright fg
    base07 = "ffffff"; # brightest
    base08 = "ff5f59"; # red
    base09 = "c0965b"; # brown/gold (orange slot)
    base0A = "d0bc00"; # yellow
    base0B = "44bc44"; # green
    base0C = "00d3d0"; # cyan
    base0D = "2fafff"; # blue
    base0E = "feacd0"; # magenta
    base0F = "c0965b"; # brown/gold
  };
}
