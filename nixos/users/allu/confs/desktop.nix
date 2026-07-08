{ config, pkgs, lib, ... }:

{
  # Empty decoration-layout strips close/minimize/maximize from GTK
  # client-side title bars (niri's prefer-no-csd already asks for SSD, but
  # not every app honors it - this catches the GTK ones that don't).
  gtk = {
    gtk3.extraConfig."gtk-decoration-layout" = ":";
    gtk4.extraConfig."gtk-decoration-layout" = ":";
  };

  programs = {
    fuzzel = {
      enable = true;
      settings = {
        main = {
          anchor = "right";
          # x-margin = 6;
          font = lib.mkForce "IBM Plex Sans:size=11"; # same family stylix uses, just bigger
          vertical-pad = 10;
          horizontal-pad = 10;
          inner-pad = 14;
          lines = 24;
          use-bold = true;
          show-actions = true;
          icons-enabled = true;
	        exit-on-keyboard-focus-loss = true;
          keyboard-focus = "on-demand";
        };
        border = {
          width = 2;
          radius = 0;
          "selection-radius" = 2;
        };
        colors.border = lib.mkForce "364c40ff"; # match waybar's border
      };
    };

    swaylock.enable = true; # Super+Alt+L in the default setting (screen locker)
    waybar = {
      enable = true;
      settings = {
        mainBar = {
          ipc = true;
          position = "right";
	        mode = "dock";
	        layer = "top";
	        # mode = "hide";
	        # start-hidden = false;

          modules-left = [ "custom/fuzzel" ];
          modules-center = [];
          modules-right = [ "group/drawer" "custom/floating" "custom/close" "pulseaudio" "clock" ];
          
	        # dont forget to rotate everything
          clock = {
	          rotate = 270;
            format = "| {:%H:%M}";
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
	          rotate = 270;
            format = "close";
            on-click = "niri msg action close-window";
          };
          
          "custom/floating" = {
	          rotate = 270;
            format = "float";
            on-click = "niri msg action toggle-window-floating";
          };

          pulseaudio = {
	          rotate = 270;
            format = "vol {volume}%";
            format-muted = "muted";
            scroll-step = 5;
            on-click = "pavucontrol";
            on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && canberra-gtk-play -i audio-volume-change";
            tooltip-format = "{desc} - {volume}%";
          };
          
          "group/drawer" = {
	          rotate = 270;
            orientation = "vertical";
            drawer = {
              click-to-reveal = true;
              transition-duration = 1200;
              transition-left-to-right = false;
            };
            modules = [
              "custom/expand"
              "custom/power"
              "custom/reboot"
              "custom/logout"
              "custom/sleep"
              "custom/awake"
              "tray"
            ];
          };
          
          "custom/expand" = {
	          rotate = 270;
            format = " ~ ";
          };
          
          tray = {
	          rotate = 270;
            icon-size = 20;
            spacing = 8;
          };
          
          "custom/sleep" = {
	          rotate =  270;
            format = "sleep";
            on-click = "systemctl suspend";
          };

          "custom/awake" = {
	          rotate = 270;
            exec = "awake-status";
            return-type = "json";
            interval = 5;
            on-click = "awake-toggle";
          };
          
          "custom/logout" = {
	          rotate = 270;
            format = "logout";
            on-click = "niri msg action quit";
          };
          
          "custom/reboot" = {
	          rotate = 270;
            format = "reboot";
            on-click = "systemctl reboot";
          };
          
          "custom/power" = {
	          rotate = 270;
            format = "poweroff";
            on-click = "systemctl poweroff";
          };
	  
	  "custom/fuzzel" = {
	          rotate = 270;
            format = "applications";
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

        .modules-right, .modules-left {
          background: #e8f0ea;
          border: 2px solid #364c40;
          margin: 0;
          padding: 4px 2px;
        }

        tooltip {
          background: #e8f0ea;
          border: 2px solid #364c40;
          border-radius: 0;
        }

        tooltip label {
          color: #364c40;
        }

        #clock, #custom-expand, #tray, #custom-close, #custom-floating, #custom-settings, #custom-power-menu, #pulseaudio, #custom-sleep, #custom-logout, #custom-reboot, #custom-power, #custom-awake, #custom-fuzzel {
          color: #364c40;
          padding: 6px 0;
        }

        #custom-expand {
          font-size: 9px;
          padding: 4px 0;
        }

        #custom-awake.active {
          color: #c60c30;
          font-weight: bold;
        }

        #custom-close:hover, #custom-floating:hover, #custom-settings:hover, #custom-power-menu:hover, #pulseaudio:hover, #custom-sleep:hover, #custom-logout:hover, #custom-reboot:hover, #custom-power:hover, #custom-awake:hover, #custom-fuzzel:hover {
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
      latitude = "50.9577971";
      longitude = "6.8021576";
      temperature.night = 5200;
    };
    mako = {
      enable = true; # notification daemon
      settings.default-timeout = 180000; # 3 min: auto-dismiss notifications
    };
    swayidle = {
      enable = true; # idle management daemon
      timeouts = [
        {
          timeout = 600; # 10 min: turn off the screen
          # swayidle's command lands directly in systemd's ExecStart=, which
          # doesn't expand $HOME (it's not a shell) - use the real path.
          command = "${config.home.homeDirectory}/.local/bin/idle-action 'niri msg action power-off-monitors'";
        }
        {
          timeout = 1800; # 30 min: suspend
          command = "${config.home.homeDirectory}/.local/bin/idle-action 'systemctl suspend'";
        }
      ];
    };
    polkit-gnome.enable = true; # polkit
    syncthing = {
      enable = true;
      tray.enable = true;
    };
    cliphist.enable = true; # clipboard history daemon, paired with the clipboard-picker script below
    network-manager-applet.enable = true; # nm-applet tray icon + nm-connection-editor
    tailscale-systray.enable = true; # tray icon for tailscale status (ported from master)
  };

  home = {
    packages = with pkgs; [
      obsidian # notetaking
      imv # lightweight Wayland-native photo viewer
      wtype # used by emoji-picker to type the selected character
      chafa file # used by lf-previewer to render image previews
      thunar thunar-volman tumbler # GUI file manager + automount + thumbnails
      pavucontrol # GUI audio/volume mixer, opened from the waybar pulseaudio module
      libcanberra-gtk3 sound-theme-freedesktop # volume-change chime (canberra-gtk-play)
    ];

    pointerCursor = {
      enable = true;
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 16;
    };

    file = {
      ".local/bin/move_conditional.sh" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          direction="$1"
          is_floating=$(niri msg --json focused-window | jq '.is_floating')
          
          if [ "$is_floating" = "true" ]; then
            niri msg action "move-window-to-workspace-''${direction}"
          else
            niri msg action "move-window-''${direction}-or-to-workspace-''${direction}"
          fi
        '';
      };

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

      ".local/bin/idle-action" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          # Runs the given idle command, unless awake-toggle has disarmed idling.
          # swayidle's systemd unit has a minimal PATH that lacks niri/systemctl,
          # so re-add the normal session locations before running anything.
          export PATH="$HOME/.local/bin:/run/current-system/sw/bin:/run/wrappers/bin:$PATH"
          [ -e "$HOME/.cache/awake-mode" ] && exit 0
          exec bash -c "$1"
        '';
      };

      ".local/bin/awake-toggle" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          # Toggles "awake mode": blocks idle-action (screen-off/suspend) until toggled off.
          sentinel="$HOME/.cache/awake-mode"
          if [ -e "$sentinel" ]; then
            rm -f "$sentinel"
            notify-send "Awake mode off" "Screen-off and sleep timers are active again"
          else
            touch "$sentinel"
            notify-send "Awake mode on" "Screen-off and sleep are blocked until toggled off"
          fi
        '';
      };

      ".local/bin/awake-status" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          # Emits waybar custom-module JSON reflecting awake-mode's sentinel file.
          if [ -e "$HOME/.cache/awake-mode" ]; then
            printf '{"text":"awake","class":"active","tooltip":"Click to allow screen-off/sleep again"}\n'
          else
            printf '{"text":"awake","class":"inactive","tooltip":"Click to block screen-off/sleep"}\n'
          fi
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
  };

  xfconf.settings.thunar = {
    "last-view" = "ThunarDetailsView"; # list mode
    "last-show-hidden" = true;
  };

  xdg = {
    # No xdg.mimeApps here on purpose: it makes mimeapps.list a read-only
    dataFile = {
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
  };
}
