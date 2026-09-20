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

          modules-left = [ "custom/fuzzel" "group/drawer" ];
          modules-center = [];
          modules-right = [ "tray" "custom/sep" "custom/floating" "custom/close" "pulseaudio" "clock" ];
          
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
            on-click-right = "swayosd-client --output-volume mute-toggle";
            tooltip-format = "{desc} - {volume}%";
          };
          
          "group/drawer" = {
	          rotate = 270;
            orientation = "vertical";
            drawer = {
              click-to-reveal = true;
              transition-duration = 1200;
              transition-left-to-right = true; # unfolds downwards, away from the top edge
            };
            modules = [
              "custom/expand"
              "custom/power"
              "custom/reboot"
              "custom/logout"
              "custom/sleep"
              "custom/awake"
            ];
          };
          
          # same "|" divider the clock carries in its format
          "custom/sep" = {
            rotate = 270;
            format = "|";
            tooltip = false;
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

        #clock, #custom-expand, #tray, #custom-close, #custom-floating, #pulseaudio, #custom-sleep, #custom-logout, #custom-reboot, #custom-power, #custom-awake, #custom-fuzzel, #custom-sep {
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

        #custom-close:hover, #custom-floating:hover, #pulseaudio:hover, #custom-sleep:hover, #custom-logout:hover, #custom-reboot:hover, #custom-power:hover, #custom-awake:hover, #custom-fuzzel:hover {
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
          # default is 700x500; doubled in both directions
          initial-window-size-pixels = "1400x1000";
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
    cliphist.enable = true; # clipboard history daemon, paired with the clipboard-picker script below
    network-manager-applet.enable = true; # nm-applet tray icon + nm-connection-editor
    tailscale-systray.enable = true; # tray icon for tailscale status (ported from master)
  };

  home = {
    packages = with pkgs; [
      imv # lightweight Wayland-native photo viewer
      zathura # lightweight vim-keys PDF viewer (bundles mupdf backend)
      swayosd # on-screen volume/mute OSD; server spawned by niri, driven via swayosd-client
      wtype # used by emoji-picker to type the selected character
      chafa file # used by lf-previewer to render image previews
      kdePackages.dolphin # GUI file manager
      kdePackages.ark # archive handling; registers Dolphin's extract/compress menu
      kdePackages.kio-extras # kio backends: mtp:/ (phones), network shares, trash
      kdePackages.kdegraphics-thumbnailers kdePackages.ffmpegthumbs # thumbnails
      kdePackages.plasma-integration # KDE Qt platform theme; makes kdeglobals authoritative
      papirus-icon-theme # fallback target for Chicago95's Inherits= chain
      p7zip # 7z format backend for ark
      pavucontrol # GUI audio/volume mixer, opened from the waybar pulseaudio module
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

      # Window sequencer for niri: one remembered size (width height) per app-id,
      # applied to every new window whether it tiles or floats, plus the last
      # floating position. Windows opening on workspace 2 get floated; every
      # other workspace tiles, stacking a new window under the column on its
      # left when both heights fit the output.
      # Started from niri.kdl (spawn-sh-at-startup).
      ".local/bin/niri-autostack" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          # Keep in sync with niri.kdl layout: gaps between tiles, and whatever
          # vertical space is left outside the column (0: struts cancel the gaps).
          gaps=16
          outer=0
          float_ws=2 # windows opening on this workspace index get floated; all others tile
          default_size="50% 60%" # width height for an app with no remembered size
          # window-presets touches this while it places its own windows
          pause="''${XDG_RUNTIME_DIR:-/tmp}/niri-autostack.pause"
          state="''${XDG_STATE_HOME:-$HOME/.local/state}/niri-autostack-sizes"
          mkdir -p "$(dirname "$state")"
          # size: app-id -> "W H [X Y]" (W is - when only a tiled height is known,
          # X Y is the last floating position)
          # tracked: windows whose resizes get remembered (not dialogs)
          declare -A app size tracked
          [[ -r $state ]] && source "$state"

          where() { # <window id> <wanted height> -> skip | float | stack | tile
            jq -rn --argjson id "$1" --arg h "$2" --argjson idx "$float_ws" \
              --argjson gaps "$gaps" --argjson outer "$outer" \
              --argjson w "$(niri msg --json windows)" \
              --argjson ws "$(niri msg --json workspaces)" \
              --argjson outs "$(niri msg --json outputs)" '
                ($w[] | select(.id == $id)) as $new
                | $new.layout.pos_in_scrolling_layout as $pos
                | if $new.is_floating or $pos == null then "skip" else
                    ($ws[] | select(.id == $new.workspace_id)) as $wsp
                    | if $wsp.idx == $idx then "float" else
                        $outs[$wsp.output].logical.height as $H
                        | (if $h | endswith("%")
                           then ($h | rtrimstr("%") | tonumber) * $H / 100
                           else $h | tonumber end) as $want
                        | [$w[] | select(.workspace_id == $new.workspace_id
                            and .layout.pos_in_scrolling_layout[0] == $pos[0] - 1)
                            | .layout.tile_size[1]] as $left
                        | ($new.layout.tile_size[1] - $new.layout.window_size[1]) as $deco
                        | if ($left | length) > 0
                            and ($left | add) + $want + $deco + $gaps * ($left | length) + $outer <= $H
                          then "stack" else "tile" end
                      end
                  end'
          }

          niri msg --json event-stream | jq --unbuffered -r '
            (.WindowsChanged.windows[]? | select(.app_id)
              | "seen \(.id) \(.is_floating) \(.app_id)"),
            (.WindowOpenedOrChanged.window | select(.app_id) | "open \(.id) \(.app_id)"),
            (.WindowLayoutsChanged.changes[]?
              | "size \(.[0]) \(.[1].pos_in_scrolling_layout != null) \(.[1].window_size[0]) \(.[1].window_size[1]) \(.[1].tile_pos_in_workspace_view // [] | join(" "))"),
            (.WindowClosed | select(.) | "close \(.id)")' |
          while read -r ev id arg; do
            case $ev in
              seen) # windows from before this script started; floating ones may be dialogs
                read -r floating a <<< "$arg"
                app[$id]=$a
                [[ $floating == false ]] && tracked[$id]=1 ;;
              close) unset "app[$id]" "tracked[$id]" ;;
              size)
                a=''${app[$id]}
                [[ $a && ''${tracked[$id]} ]] || continue
                read -r tiled w h x y <<< "$arg"
                # a tiled window's width belongs to its column and it has no
                # position, so keep the old ones
                [[ $tiled == true ]] && { read -r w _ x y <<< "''${size[$a]}"; w=''${w:--}; }
                new="$w $h''${x:+ $x $y}"
                if [[ ''${size[$a]} != "$new" ]]; then
                  size[$a]=$new
                  declare -p size > "$state"
                fi ;;
              open) # also fires on title changes etc; only act on first sight
                [[ ''${app[$id]} ]] && continue
                app[$id]=$arg
                # a pause file older than 60 s is a leftover, not a running load
                if [[ -e $pause ]] && (( $(date +%s) - $(stat -c %Y "$pause") < 60 )); then
                  continue
                fi
                read -r w h x y <<< "''${size[$arg]:-$default_size}"
                mode=$(where "$id" "$h")
                [[ $mode == skip || -z $mode ]] && continue
                tracked[$id]=1
                [[ $mode == float ]] && niri msg action move-window-to-floating --id "$id"
                [[ $mode == stack ]] && niri msg action consume-or-expel-window-left --id "$id"
                # a stacked window takes the width of its column
                [[ $mode != stack && $w != - ]] && niri msg action set-window-width --id "$id" "$w"
                niri msg action set-window-height --id "$id" "$h"
                [[ $mode == float && $x ]] && niri msg action move-floating-window --id "$id" -x "$x" -y "$y" ;;
            esac
          done
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

      ".local/share/emoji-picker/emojis.txt".text = builtins.readFile ./confs/emojis.txt;

      # Chime played by the niri volume keys (see confs/niri.kdl); the
      # static kdl can't reference a store path, so link it to a fixed one.
      ".local/share/sounds/volume-change.oga".source =
        "${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/audio-volume-change.oga";

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

      # Presets live in ~/.local/state/niri-presets/<name>.json.
      ".local/bin/window-presets" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          # Save the focused workspace's windows (app, tiled or floating, size,
          # position) as a preset, or open a saved preset on the focused workspace.
          dir="''${XDG_STATE_HOME:-$HOME/.local/state}/niri-presets"
          # niri-autostack leaves new windows alone while this file is fresh
          pause="''${XDG_RUNTIME_DIR:-/tmp}/niri-autostack.pause"
          wait=12 # seconds to wait for a launched app's window
          mkdir -p "$dir"

          save() {
            local ws data name
            ws=$(niri msg --json workspaces | jq -c '.[] | select(.is_focused)')
            # tiled windows first, in column/row order, so loading rebuilds the columns
            data=$(niri msg --json windows | jq --argjson ws "$ws" '
              [.[] | select(.workspace_id == $ws.id and .app_id)
                | {app_id, floating: .is_floating, size: .layout.window_size,
                   pos: .layout.tile_pos_in_workspace_view, cell: .layout.pos_in_scrolling_layout}]
              | sort_by(.floating, .cell)')
            if [[ $(jq length <<< "$data") == 0 ]]; then
              notify-send "Window presets" "No windows on this workspace"
              return
            fi
            # ponytail: "first syllable" = first 3 letters of the app-id's last dotted
            # part (org.kde.dolphin -> dol); real syllable splitting if names collide
            name=$(jq -r --argjson ws "$ws" '
              [$ws.name // "ws\($ws.idx)"]
              + [.[].app_id | split(".") | last | ascii_downcase | .[:3]] | join("-")' <<< "$data")
            printf '%s\n' "$data" > "$dir/$name.json"
            notify-send "Window presets" "Saved $name"
          }

          launch() { # <app-id>: run the Exec line of its desktop entry, else the app-id itself
            local dirs p cmd
            IFS=: read -ra dirs <<< "''${XDG_DATA_HOME:-$HOME/.local/share}:''${XDG_DATA_DIRS:-/run/current-system/sw/share}"
            for p in "''${dirs[@]}"; do
              [[ -r $p/applications/$1.desktop ]] || continue
              cmd=$(sed -n 's/^Exec=//p' "$p/applications/$1.desktop" | head -1 | sed 's/ *%[a-zA-Z]//g')
              break
            done
            niri msg action spawn-sh -- "''${cmd:-$1}"
          }

          apply() { # <window id> <preset entry>
            local id=$1 floating w h x y row
            read -r floating w h x y row < <(jq -r '[.floating, .size[0], .size[1],
              (.pos // [0, 0])[0], (.pos // [0, 0])[1], (.cell // [0, 1])[1]] | @tsv' <<< "$2")
            if [[ $floating == true ]]; then
              niri msg action move-window-to-floating --id "$id"
            else
              niri msg action move-window-to-tiling --id "$id"
              # a row below the first stacks into the column opened just before it
              ((row > 1)) && niri msg action consume-or-expel-window-left --id "$id"
            fi
            # a stacked window takes the width of its column
            ((row > 1)) || niri msg action set-window-width --id "$id" "$w"
            niri msg action set-window-height --id "$id" "$h"
            [[ $floating == true ]] && niri msg action move-floating-window --id "$id" -x "$x" -y "$y"
          }

          load() { # <preset file>
            local n i t entry app before id
            trap 'rm -f "$pause"' EXIT
            n=$(jq length "$1")
            for ((i = 0; i < n; i++)); do
              touch "$pause"
              entry=$(jq -c ".[$i]" "$1")
              app=$(jq -r .app_id <<< "$entry")
              before=$(niri msg --json windows | jq -c '[.[].id]')
              launch "$app"
              id=
              for ((t = 0; t < wait * 4; t++)); do
                sleep 0.25
                id=$(niri msg --json windows | jq --argjson before "$before" --arg app "$app" '
                  first(.[] | select(.app_id == $app and (.id | IN($before[]) | not)) | .id)')
                [[ $id ]] && break
              done
              # single-instance apps that are already running open no new window
              [[ $id ]] && apply "$id" "$entry"
            done
          }

          presets() { for f in "$dir"/*.json; do [[ -e $f ]] && basename "$f" .json; done; }

          choice=$({
            echo "Save this workspace"
            presets
            echo "Delete a preset"
          } | fuzzel --dmenu --prompt="Presets: ")
          case $choice in
            "") ;;
            "Save this workspace") save ;;
            "Delete a preset")
              choice=$(presets | fuzzel --dmenu --prompt="Delete: ")
              [[ $choice && -e $dir/$choice.json ]] && rm "$dir/$choice.json" \
                && notify-send "Window presets" "Deleted $choice" ;;
            *) [[ -r $dir/$choice.json ]] && load "$dir/$choice.json" ;;
          esac
        '';
      };
    };
  };

  # KDE apps take their icon theme from kdeglobals, which stylix's KDE target
  # does not write; it only covers fonts and colours. KConfig cascades, so this
  # minimal file overrides just [Icons] and leaves the rest coming from the
  # stylix-kde-config dir on XDG_CONFIG_DIRS. Nix-managed means read-only -
  # fine here since nothing running writes kdeglobals without a Plasma session.
  # Font sizes come from stylix so a family change there still propagates here;
  # only the point size is overridden, since Qt renders these a shade larger
  # than the GTK side at the same nominal size.
  # Compositor and edge-gesture configs: moved here from home.nix so headless
  # hosts don't link dead niri/waycorner files.
  xdg.configFile."niri/config.kdl".source = ./confs/niri.kdl;
  xdg.configFile."waycorner/config.toml".source = ./confs/waycorner.toml;

  xdg.configFile."kdeglobals".text =
    let
      f = config.stylix.fonts;
      kdeFont = name: size: "${name},${toString size},-1,5,50,0,0,0,0,0";
      ui = f.sizes.applications - 1;
    in ''
      [Icons]
      Theme=Chicago95

      [General]
      font[$i]=${kdeFont f.sansSerif.name ui}
      menuFont[$i]=${kdeFont f.sansSerif.name ui}
      toolBarFont[$i]=${kdeFont f.sansSerif.name ui}
      smallestReadableFont[$i]=${kdeFont f.sansSerif.name (ui - 1)}
      fixed[$i]=${kdeFont f.monospace.name ui}
    '';

  # Qt widget style. Stylix's qt target pins style.name = "kvantum"; the Win9x
  # look wants Qt's own built-in Windows style (shipped in qtbase, no package),
  # so that target is off here and qt is configured directly. Costs stylix's
  # Qt colour theming - the Windows style brings its own grey palette anyway.
  stylix.targets.qt.enable = false;
  # platformTheme "kde" loads KDEPlasmaPlatformTheme6.so from
  # plasma-integration, which is what actually reads kdeglobals for fonts,
  # icons and colours. The previous "qtct" resolved to QT_QPA_PLATFORMTHEME=
  # qt5ct, a plugin no Qt6 app can load, so Dolphin silently fell back to
  # Qt's built-in defaults and ignored kdeglobals entirely.
  qt = {
    enable = true;
    platformTheme.name = "kde";
    style.name = "Windows";
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

      "applications/window-presets.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Window Presets
        Comment=Save this workspace's windows as a preset, or open a saved one
        Exec=window-presets
        Icon=preferences-system-windows
        Categories=Utility;
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

      # plain foot; foot.desktop exists too but is named "Foot", this keeps the
      # two terminal entries next to each other in fuzzel
      "applications/foot-plain.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Terminal
        Comment=Open a foot terminal
        Exec=foot
        Icon=utilities-terminal
        Categories=System;
        Terminal=false
      '';

      # same session tmux attaches/creates as the `tux` shell alias
      "applications/foot-tmux.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Terminal (tmux)
        Comment=Open a foot terminal attached to the main tmux session
        Exec=foot -e ${pkgs.tmux}/bin/tmux new-session -A -s main
        Icon=utilities-terminal
        Categories=System;
        Terminal=false
      '';
    };
  };
}
