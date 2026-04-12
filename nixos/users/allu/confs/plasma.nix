{ config, pkgs, ... }:

{
  # imports = [<plasma-manager/modules>];

  programs.rofi = {
    enable = true;
    font = "Lucida Sans 10";
    theme = builtins.toFile "powershell-dmenu.rasi" ''
      @theme "dmenu"

      * {
        background-color: #012456;
        text-color: #FFFFFF;
      }

      element selected {
        background-color: #FFFFCC;
        text-color: #012456;
      }
    '';
    plugins = with pkgs; [ rofi-calc ];
    terminal = "\${pkgs.foot}/bin/foot";
  };

  programs.plasma = {
    enable = true; # enable and configure plasma settings
    overrideConfig = true; # default all else

    workspace = {
      theme = "reactplus";
      lookAndFeel = "org.magpie.reactplus.desktop"; # not used with windowDecor
      iconTheme = "Memphis98";
      colorScheme = "ReactionaryLeaves";
      cursor = {
        size = 24;
        theme = "Hackneyed";
      };
      clickItemTo = "select";
      # wallpaperPlainColor = "44,81,80";
      wallpaper = ./art002e012279.jpg;
      wallpaperFillMode = "pad"; # preserveAspectCrop
      wallpaperBackground.color = "0,0,0"; # R,G,B
    };

    configFile."kwinrc" = {
      "org.kde.kdecoration2" = {
        # Use "None" to strip all side/bottom borders
        "BorderSize" = "Tiny";
        "BorderSizeAuto" = false;
      };
      "TabBox" = {
        # 'informative' or 'text' layouts provide a cleaner, list-based UI
        "LayoutName" = "informative"; 
        "ShowDesktopMode" = 1;
      };
    };

    fonts = {
      general = { family = "Lucida Sans"; pointSize = 10; };
      fixedWidth = { family = "Fixedsys Excelsior 3.01"; pointSize = 10; };
      small = { family = "Lucida Sans"; pointSize = 8; };
      toolbar = { family = "Fixedsys Excelsior 3.01"; pointSize = 10; };
      menu = { family = "Lucida Sans"; pointSize = 10; };
      windowTitle = { family = "Fixedsys Excelsior 3.01"; pointSize = 11; };
    };

    hotkeys.commands = {
      "rofi-app" = {
        name = "Rofi App Launcher";
        key = "Alt+Space";
        command = "rofi -show drun";
      };
    };
    
    shortcuts = {
      "services/plasma-manager-commands.desktop" = {
        "rofi-app" = "Meta+Space";
        "rofi-window" = "Meta+Tab";
      };
      "org.kde.krunner.desktop" = {
        "_launch" = [ ];
      };
      "krunner.desktop" = {
        "_launch" = [ ];
      };
      # plasmashell = {
      #   "activate application launcher" = [ ];
      # };
      kwin = {
        "Window Fullscreen" = "Meta+Shift+M";
        "Window Maximize" = "Meta+M";
        "Window Close" = "Meta+Q";
        "Window Kill" = "Meta+Shift+Q";
      };
    };

    input.keyboard = {
      repeatDelay = 280;
      repeatRate = 40;
    };

    kwin = {
      virtualDesktops.names = [ "Main" "Extra" ];
      nightLight = {
        enable = true;
        mode = "times";
        temperature.night = 5400;
        time.evening = "17:00";
        time.morning = "08:00";
        transitionTime = 3;
      };
      effects = {
        blur.enable = false;
        desktopSwitching.animation = "off";
        minimization.animation = "off";
        translucency.enable = false;
        windowOpenClose.animation = "off";
      };
      titlebarButtons.left = [ ];
      titlebarButtons.right = [ "minimize" "keep-above-windows" "maximize" "close" ];
    };

    configFile = {
      "dolphinrc" = {
        DetailsMode.PreviewSize = 16;
        General.EditableUrl = true;
        General.ShowFullPath = true;
      };
      "kdeglobals" = {
        KDE.widgetStyle = "Windows";
        General = {
          TerminalApplication = "foot";
          TerminalService = "foot.desktop";
        };
      };
    };

    # check out examples in https://github.com/nix-community/plasma-manager/blob/trunk/examples/home.nix
    # Here I have a simple vertical mac style menu panel with a app launcher, manager, systray and a clock
    panels = [
      { 
        location = "top";
        alignment = "center";
        floating = false;
        height = 28; # different screens, different resolutions...
        hiding = "dodgewindows"; # normalpanel
        lengthMode = "fill";
        opacity = "opaque";
        widgets = [
          "org.kde.plasma.marginsseparator"
          {
            kicker = {
              behavior.sortAlphabetically = false;
              behavior.flattenCategories = true;
              behavior.showIconsOnRootLevel = false;
              categories.show.recentApplications = false;
              categories.show.recentFiles = false;
              categories.order = "recentFirst";
              search.alignResultsToBottom = false;
              search.expandSearchResults = false;
            }; 
          }
	  {
	    name = "org.kde.plasma.windowlist";
	    config.General.showIcon = false;
	  }
          "org.kde.plasma.marginsseparator"
	  "org.kde.plasma.appmenu"
	  "org.kde.plasma.panelspacer"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.marginsseparator"
          {
            name = "org.kde.plasma.digitalclock";
            config.Appearance.showDate = false;
          }
        ];
      }
    ];

    # TODO: tiling presets with polonium
  };
}
