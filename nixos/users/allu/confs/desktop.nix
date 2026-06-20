{ pkgs, ... }:

{
  programs = {
    fuzzel = {
      enable = true;
      settings = {
        main = {
          anchor = "right";
          x-margin = 6;
          vertical-pad = 6;
          horizontal-pad = 6;
          inner-pad = 4;
          lines = 32;
          use-bold = true;
          show-actions = true;
          icons-enabled = true;
        };
        border = {
          width = 2;
          radius = 0;
          "selection-radius" = 2;
        };
      };
    };

    swaylock.enable = true; # Super+Alt+L in the default setting (screen locker)
    waybar = {
      enable = true;
      settings = {
        mainBar = {
          ipc = true;
          layer = "top";
          position = "bottom";
          exclusive = false;

          modules-left = [];
          modules-center = [];
          modules-right = [ "group/drawer" "custom/floating" "custom/close" "pulseaudio" "custom/fuzzel" "clock" ];
          
          clock = {
            format = "{:%H:%M}";
	    tooltip-format = "<tt>{calendar}</tt>";
            calendar = {
              mode = "month";
              mode-mon-col = 3;
              weeks-pos = "right";
              on-scroll = 1;
              # Plain text inherits "tooltip label"'s Stylix-injected color;
              # bold/underline alone distinguish months/weekdays/today.
              format = {
                months = "<b>{}</b>";
                days = "{}";
                weeks = "W{}";
                weekdays = "<b>{}</b>";
                today = "<b><u>{}</u></b>";
              };
            };
            on-click = "fuzzel";
          };
          
          "custom/close" = {
            format = "close";
            on-click = "niri msg action close-window";
          };
          
          "custom/floating" = {
            format = "float";
            on-click = "niri msg action toggle-window-floating";
          };

          pulseaudio = {
            format = "vol {volume}%";
            format-muted = "muted";
            scroll-step = 5;
            on-click = "pavucontrol";
            on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            tooltip-format = "{desc} - {volume}%";
          };
          
          "group/drawer" = {
            orientation = "horizontal";
            drawer = {
              # Slow close animation so it doesn't snap shut the instant the
              # mouse leaves - waybar has no separate "stay open" delay knob,
              # so a long transition is the only way to make it linger.
              transition-duration = 1200;
              transition-left-to-right = false;
            };
            modules = [
              "custom/expand"
              "custom/power"
              "custom/reboot"
              "custom/logout"
              "custom/sleep"
              "tray"
            ];
          };
          
          "custom/expand" = {
            format = " ~ ";
          };
          
          tray = {
            icon-size = 20;
            spacing = 8;
          };
          
          "custom/sleep" = {
            format = "sleep";
            on-click = "systemctl suspend";
          };
          
          "custom/logout" = {
            format = "logout";
            on-click = "niri msg action quit";
          };
          
          "custom/reboot" = {
            format = "reboot";
            on-click = "systemctl reboot";
          };
          
          "custom/power" = {
            format = "poweroff";
            on-click = "systemctl poweroff";
          };
	  
	  "custom/fuzzel" = {
            format = "|";
	    on-click = "fuzzel";
	  };
        };
      };
      # window#waybar is left transparent/borderless so only .modules-right
      # renders as a compact floating box, instead of a full-width bar.
      style = ''
        * {
          font-family: IBM Plex Mono;
          font-size: 12;
        }

        window#waybar {
          background: transparent;
          border: none;
        }

        .modules-right {
          background: #e8f0ea;
          border: 2px solid #364c40;
          margin: 0;
          padding: 2px 4px;
        }

        tooltip {
          background: #e8f0ea;
          border: 2px solid #364c40;
          border-radius: 0;
        }

        tooltip label {
          color: #364c40;
        }

        #clock, #custom-expand, #tray, #custom-close, #custom-floating, #custom-settings, #custom-power-menu, #pulseaudio, #custom-sleep, #custom-logout, #custom-reboot, #custom-power {
          color: #364c40;
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
    };

    foot = {
      enable = true;
      settings = {
        main = {
          font = "Aporetic Serif Mono:size=10";
          font-bold = "Aporetic Serif Mono:size=10";
          font-italic = "Aporetic Serif Mono:size=10";
          font-bold-italic = "Aporetic Serif Mono:size=10";
        };
      };
    };

    brave = {
      enable = true;
      commandLineArgs = [ "--enable-features=UseOzonePlatform --ozone-platform=wayland" ];
    };
  };

  services = {
    wlsunset = {
      enable = true; # night light: warm gamma after dark
      latitude = 50.9577971;
      longitude = 6.8021576;
    };
    mako.enable = true; # notification daemon
    swayidle.enable = true; # idle management daemon
    polkit-gnome.enable = true; # polkit
    syncthing = {
      enable = true;
      tray.enable = true;
    };
    cliphist.enable = true; # clipboard history daemon, paired with the clipboard-picker script below
    network-manager-applet.enable = true; # nm-applet tray icon + nm-connection-editor
    tailscale-systray.enable = true; # tray icon for tailscale status (ported from master)
  };

  home.packages = with pkgs; [
    imv # lightweight Wayland-native photo viewer
    wtype # used by emoji-picker to type the selected character
    chafa file # used by lf-previewer to render image previews
    thunar thunar-volman tumbler # GUI file manager + automount + thumbnails
    pavucontrol # GUI audio/volume mixer, opened from the waybar pulseaudio module
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "image/png" = "imv.desktop";
      "image/jpeg" = "imv.desktop";
      "image/gif" = "imv.desktop";
      "image/webp" = "imv.desktop";
      "image/bmp" = "imv.desktop";
    };
  };

  home.file = {
    ".local/bin/pick-color" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        # hyprpicker -a copies the picked hex straight to the clipboard
        color=$(hyprpicker -a)
        [ -n "$color" ] && notify-send "Color picked" "$color"
      '';
    };

    ".local/bin/clipboard-picker" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        cliphist list | fuzzel --dmenu | cliphist decode | wl-copy
      '';
    };

    ".local/bin/emoji-picker" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        selected=$(fuzzel --dmenu < "$HOME/.local/share/emoji-picker/emojis.txt" | cut -d' ' -f1)
        [ -n "$selected" ] && wtype "$selected"
      '';
    };

    ".local/share/emoji-picker/emojis.txt".text = builtins.readFile ./emojis.txt;

    ".local/bin/lf-previewer" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        # lf calls this as: lf-previewer <path> <preview-width> <preview-height> <x> <y>
        file="$1"
        width="$2"
        height="$3"

        case "$(file --mime-type -Lb "$file")" in
          image/*)
            chafa --format=sixels --size="$width"x"$height" "$file"
            ;;
          *)
            bat --color=always --style=numbers --line-range=:500 "$file" 2>/dev/null || cat "$file"
            ;;
        esac
      '';
    };

    ".local/bin/power-menu" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        choice=$(printf "Lock\nSleep\nReboot\nPower Off\nLog Out\n" | fuzzel --dmenu --prompt="Power: ")
        case "$choice" in
          "Lock") swaylock ;;
          "Sleep") systemctl suspend ;;
          "Reboot") systemctl reboot ;;
          "Power Off") systemctl poweroff ;;
          "Log Out") niri msg action quit ;;
        esac
      '';
    };

    ".local/bin/settings-menu" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        choice=$(printf "Wi-Fi Settings\nBluetooth Settings\nVPN Connections\n" | fuzzel --dmenu --prompt="Settings: ")
        case "$choice" in
          "Wi-Fi Settings") nm-connection-editor ;;
          "Bluetooth Settings") blueman-manager ;;
          "VPN Connections")
            vpn=$(nmcli -t -f NAME,TYPE connection show | awk -F: '$2=="vpn"||$2=="wireguard"{print $1}' | fuzzel --dmenu --prompt="VPN: ")
            [ -n "$vpn" ] && nmcli connection up "$vpn"
            ;;
        esac
      '';
    };
  };

  xdg.dataFile = {
    "applications/pick-color.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Color Picker
      Comment=Pick a color from the screen and copy its hex code
      Exec=pick-color
      Icon=gtk-color-picker
      Categories=Utility;
      Terminal=false
    '';

    "applications/clipboard-picker.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Clipboard History
      Comment=Browse and re-copy clipboard history
      Exec=clipboard-picker
      Icon=edit-paste
      Categories=Utility;
      Terminal=false
    '';

    # keep these around still so that I could select them from fuzzel
    "applications/power-menu.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Power Menu
      Comment=Lock, sleep, reboot, power off, or log out
      Exec=power-menu
      Icon=system-shutdown
      Categories=System;
      Terminal=false
    '';

    "applications/settings-menu.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Settings Menu
      Comment=Wi-Fi, Bluetooth, and VPN connections
      Exec=settings-menu
      Icon=preferences-system
      Categories=Settings;
      Terminal=false
    '';

    "applications/emoji-picker.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Emoji Picker
      Comment=Pick an emoji and type it into the focused window
      Exec=emoji-picker
      Icon=face-smile
      Categories=Utility;
      Terminal=false
    '';

    "applications/monitor-layout.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Monitor Layout
      Comment=Arrange and configure connected displays
      Exec=wdisplays
      Icon=video-display
      Categories=Settings;
      Terminal=false
    '';

    "applications/font-viewer.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Font Viewer
      Comment=Preview installed fonts
      Exec=foot -e fontpreview
      Icon=preferences-desktop-font
      Categories=Utility;
      Terminal=false
    '';
  };
}
