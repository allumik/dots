{ config, pkgs, ... }:

{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "Lucida Sans:size=11";
        anchor = "top";
	y-margin = 10;
	vertical-pad = 6;
	horizontal-pad = 6;
	inner-pad = 4;
	lines = 5;
	use-bold = true;
	show-actions = true;
	list-executables-in-path = true;
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
    kscreenlocker.appearance.wallpaperPlainColor = "44,81,80";

    configFile."kwinrc" = {
      "org.kde.kdecoration2" = {
        # Use "None" to strip all side/bottom borders
        "BorderSize" = "Tiny";
        "BorderSizeAuto" = false;
      };
      "TabBox" = {
        "LayoutName" = "Compact"; 
	"ShowTabBox" = false;
      };
      "Windows" = {
	"Placement" = "Smart";
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
      "fuzzel-app" = {
        name = "Fuzzel App Launcher";
        key = "Alt+Space";
        command = "fuzzel";
      };
    };

    shortcuts = {
      # enable the fuzzel app, and disable the krunner
      "services/plasma-manager-commands.desktop" = {
        "fuzzel-app" = "Meta+Space";
      };
      "org.kde.krunner.desktop" = {
        "_launch" = [ ];
      };
      "krunner.desktop" = {
        "_launch" = [ ];
      };
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
      "klaunchrc" = {
        Feedback = {
          BusyCursor = false;
          TaskbarButton = false;
        };
      };
    };

    # check out examples in https://github.com/nix-community/plasma-manager/blob/trunk/examples/home.nix
    # Here I have a simple vertical mac style menu panel with a app launcher, manager, systray and a clock
    panels = [
      { 
        location = "bottom";
        alignment = "center";
        floating = false;
        height = 32; # different screens, different resolutions...
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
          "org.kde.plasma.marginsseparator"
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
