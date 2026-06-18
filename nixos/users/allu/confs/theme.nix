# confs/theme.nix
#
# Day/night theme switching between Modus Operandi (light) and Modus
# Vivendi (dark), https://protesilaos.com/emacs/modus-themes-colors.
#
# Stylix (hosts/stylix.nix) only bakes one fixed scheme in at build time,
# so it can't drive a live toggle. Instead:
#   - fuzzel and waybar get TWO full config variants generated below
#     (fuzzel-light.ini/fuzzel-dark.ini, style-light.css/style-dark.css).
#     The files actually read at runtime (fuzzel.ini, style-current.css)
#     are plain symlinks, NOT managed by home-manager, so
#     ~/.local/bin/theme-switch can repoint them without a rebuild.
#   - GTK apps (Thunar etc.) use the adw-gtk3 theme, which natively
#     follows the "color-scheme" gsetting - so toggling that gsetting is
#     enough, no custom CSS needed (this is why stylix.targets.gtk is
#     disabled: Stylix's injected gtk.css would otherwise override it).
#   - swaybg (wallpaper fill) is restarted with the new color.
#   - niri's focus-ring and foot/bat (Stylix-driven) are NOT part of the
#     swap - seeded once at build time and left alone. Recoloring niri
#     would require splitting config.kdl into a templated/symlinked file
#     the same way as fuzzel/waybar, and foot's colors can't be live
#     reloaded into already-open terminals anyway. The focus-ring uses
#     Modus Vivendi's red, which reads acceptably on both backgrounds.
{ config, pkgs, lib, ... }:

let
  operandi = {
    bg = "ffffff"; border = "9f9f9f"; text = "000000"; fgDim = "595959";
    region = "bdbdbd"; red = "a60000"; yellow = "6f5500"; green = "006800";
    cyan = "005e8b"; blue = "0031a9"; magenta = "721045"; brown = "80601f";
  };
  vivendi = {
    bg = "000000"; border = "646464"; text = "ffffff"; fgDim = "989898";
    region = "5a5a5a"; red = "ff5f59"; yellow = "d0bc00"; green = "44bc44";
    cyan = "00d3d0"; blue = "2fafff"; magenta = "feacd0"; brown = "c0965b";
  };

  mkFuzzelIni = c: ''
    [main]
    font=IBM Plex Sans:size=10
    anchor=right
    x-margin=6
    vertical-pad=6
    horizontal-pad=6
    inner-pad=4
    lines=32
    use-bold=yes
    show-actions=yes
    icon-theme=Papirus
    icons-enabled=yes

    [border]
    width=2
    radius=0
    selection-radius=2

    [colors]
    background=${c.bg}ff
    border=${c.border}ff
    text=${c.text}ff
    prompt=${c.blue}ff
    placeholder=${c.fgDim}ff
    input=${c.text}ff
    match=${c.red}ff
    selection=${c.region}ff
    selection-text=${c.text}ff
    selection-match=${c.red}ff
    counter=${c.cyan}ff
  '';

  mkWaybarStyle = c: ''
    * {
      font-family: IBM Plex Mono;
      font-size: 12;
    }

    window#waybar {
      background: transparent;
      border: none;
    }

    .modules-right {
      background: #${c.bg};
      border: 2px solid #${c.border};
      margin: 0;
      padding: 2px 4px;
    }

    tooltip {
      background: #${c.bg};
      border: 2px solid #${c.border};
      border-radius: 0;
    }

    tooltip label {
      color: #${c.text};
    }

    #clock, #custom-expand, #tray, #custom-close, #custom-floating, #custom-settings, #custom-power-menu, #pulseaudio, #custom-sleep, #custom-logout, #custom-reboot, #custom-power {
      color: #${c.text};
      padding: 0 6px;
    }

    #custom-expand {
      font-size: 9px;
      padding: 0 4px;
    }

    #custom-close:hover, #custom-floating:hover, #custom-settings:hover, #custom-power-menu:hover, #pulseaudio:hover, #custom-sleep:hover, #custom-logout:hover, #custom-reboot:hover, #custom-power:hover {
      text-decoration: underline;
    }
  '';
in
{
  # These are home-manager-only Stylix targets, so they have to be disabled
  # here rather than in hosts/stylix.nix (which is a NixOS-level module and
  # doesn't expose them).
  stylix.targets.fuzzel.enable = false;
  stylix.targets.waybar.enable = false;
  stylix.targets.gtk.enable = false;

  gtk = {
    enable = true;
    theme = {
      package = pkgs.adw-gtk3;
      name = "adw-gtk3"; # follows the color-scheme gsetting live
    };
    gtk4.extraConfig.gtk-application-prefer-dark-theme = false;
  };

  home.packages = [ pkgs.glib ]; # gsettings, used by theme-switch

  xdg.configFile = {
    "fuzzel/fuzzel-light.ini".text = mkFuzzelIni operandi;
    "fuzzel/fuzzel-dark.ini".text = mkFuzzelIni vivendi;
    "waybar/style-light.css".text = mkWaybarStyle operandi;
    "waybar/style-dark.css".text = mkWaybarStyle vivendi;
  };

  home.file.".local/bin/theme-switch" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Switch between Modus Operandi (light) and Modus Vivendi (dark).
      # Called with no args: auto-detect from the current hour.
      # Called with "light"/"dark": forced, used by the systemd timers.
      set -euo pipefail

      day_start=7
      night_start=19

      mode="''${1:-}"
      if [ -z "$mode" ]; then
        hour=$(date +%H)
        hour=$((10#$hour))
        if [ "$hour" -ge "$day_start" ] && [ "$hour" -lt "$night_start" ]; then
          mode=light
        else
          mode=dark
        fi
      fi

      case "$mode" in
        light) bg=ffffff ;;
        dark) bg=000000 ;;
        *) echo "usage: theme-switch [light|dark]" >&2; exit 1 ;;
      esac

      ln -sf "$HOME/.config/fuzzel/fuzzel-$mode.ini" "$HOME/.config/fuzzel/fuzzel.ini"
      ln -sf "$HOME/.config/waybar/style-$mode.css" "$HOME/.config/waybar/style-current.css"

      pkill -x waybar 2>/dev/null || true
      setsid -f waybar >/dev/null 2>&1 || true

      pkill -x swaybg 2>/dev/null || true
      setsid -f swaybg -c "#$bg" >/dev/null 2>&1 || true

      if [ "$mode" = "dark" ]; then
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
      else
        gsettings set org.gnome.desktop.interface color-scheme 'default' 2>/dev/null || true
      fi
    '';
  };

  # Make sure the symlinks exist after every rebuild (first activation ever,
  # or if they were somehow removed) without clobbering a live choice made
  # by theme-switch in between rebuilds.
  home.activation.themeDefaults = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    [ -e "$HOME/.config/fuzzel/fuzzel.ini" ] || run ln -sf "$HOME/.config/fuzzel/fuzzel-dark.ini" "$HOME/.config/fuzzel/fuzzel.ini"
    [ -e "$HOME/.config/waybar/style-current.css" ] || run ln -sf "$HOME/.config/waybar/style-dark.css" "$HOME/.config/waybar/style-current.css"
  '';

  systemd.user.services.theme-switch-day = {
    Unit.Description = "Switch to Modus Operandi (light) theme";
    Service = {
      Type = "oneshot";
      ExecStart = "${config.home.homeDirectory}/.local/bin/theme-switch light";
    };
  };
  systemd.user.timers.theme-switch-day = {
    Unit.Description = "Daily light theme switch";
    Timer = {
      OnCalendar = "07:00";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  systemd.user.services.theme-switch-night = {
    Unit.Description = "Switch to Modus Vivendi (dark) theme";
    Service = {
      Type = "oneshot";
      ExecStart = "${config.home.homeDirectory}/.local/bin/theme-switch dark";
    };
  };
  systemd.user.timers.theme-switch-night = {
    Unit.Description = "Daily dark theme switch";
    Timer = {
      OnCalendar = "19:00";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
