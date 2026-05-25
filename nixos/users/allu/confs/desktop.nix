{ config, pkgs, ... }:

{
  programs = {
    fuzzel = {
      enable = true;
      settings = {
        main = {
          font = "IBM Plex Sans:size=12";
          anchor = "right";
          x-margin = 6;
          vertical-pad = 6;
          horizontal-pad = 6;
          inner-pad = 4;
          lines = 32;
          use-bold = true;
          show-actions = true;
          # list-executables-in-path = true;
        };
        border = {
          width = 2;
          radius = 0;
          selection-radius = 2;
        };
        colors = {
          background = "b8b8b8ff";
          border = "9b9b9bff";
          text = "000000ff";
          prompt = "ae3623ff";
          placeholder = "969696ff";
          input = "000000ff";
          match = "e15b36ff";
          selection = "969696ff";
          selection-text = "902018ff";
          selection-match = "e15b36ff";
          counter = "7f849cff";
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
          position = "top";
          exclusive = false;
          
          modules-left = [];
          modules-center = [];
          modules-right = [ "group/drawer" "custom/floating" "custom/close" "custom/fuzzel" "clock" ];
          
          clock = {
            format = "{:%H:%M}";
	    tooltip-format = "<tt>{calendar}</tt>";
            calendar = {
              mode = "month";
              mode-mon-col = 3;
              weeks-pos = "right";
              on-scroll = 1;
              format = {
                months = "<span color='#000000'><b>{}</b></span>";
                days = "<span color='#000000'>{}</span>";
                weeks = "<span color='#9b9b9b'>W{}</span>";
                weekdays = "<span color='#000000'><b>{}</b></span>";
                today = "<span color='#ae3623'><b><u>{}</u></b></span>";
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
          
          "group/drawer" = {
            orientation = "horizontal";
            drawer = {
              transition-duration = 300;
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
            format = "~";
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
      style = ''
        * {
          font-family: IBM Plex Mono;
          font-size: 14;
        }

        window#waybar {
          background: transparent;
          border: none;
        }

        .modules-right {
          background: #b8b8b8;
          border: 2px solid #9b9b9b;
          margin: 0;
          padding: 2px 4px;
        }

	tooltip {
          background: #b8b8b8;
          border: 2px solid #9b9b9b;
          border-radius: 0;
        }

        tooltip label {
          color: #000000;
        }

        #clock, #custom-expand, #tray, #custom-close, #custom-floating, #custom-sleep, #custom-logout, #custom-reboot, #custom-power {
          color: #000000;
          padding: 0 6px;
        }

        #custom-close:hover, #custom-floating:hover, #custom-sleep:hover, #custom-logout:hover, #custom-reboot:hover, #custom-power:hover {
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
    mako.enable = true; # notification daemon
    swayidle.enable = true; # idle management daemon
    polkit-gnome.enable = true; # polkit
    syncthing = {
      enable = true;
      tray.enable = true;
    };
  };
} 
