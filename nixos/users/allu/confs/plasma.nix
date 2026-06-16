{ config, pkgs, ... }:

{
  programs.plasma = {
    enable = true; # enable and configure plasma settings
    overrideConfig = false; # this overwrites all other conf if set

    workspace = {
      clickItemTo = "select";
      # wallpaperPlainColor = "44,81,80";
      wallpaper = ./59028ca.png;
      wallpaperFillMode = "pad"; # preserveAspectCrop
      wallpaperBackground.color = "44,81,80"; # R,G,B
    };
    kscreenlocker.appearance.wallpaperPlainColor = "44,81,80";

    configFile."kwinrc" = {
      "org.kde.kdecoration2" = {
        # Use "None" to strip all side/bottom borders
        "BorderSize" = "Tiny";
        "BorderSizeAuto" = true;
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

    shortcuts = {
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
        time.evening = "19:00";
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
	General.BrowseThroughArchives = true;
      };
      "kdeglobals" = {
        # KDE.widgetStyle = "Windows";
        KDE.AutomaticLookAndFeel = true;
        Icons.Theme.persistent = true;
        General = {
          ColorScheme.persistent = true;
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
        location = "top";
        alignment = "center";
        floating = false;
        height = 32; # different screens, different resolutions...
        hiding = "normalpanel"; # dodgewindows
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
            iconTasks = {
              iconsOnly = true;
              appearance.fill = true;
              appearance.showTooltips = false;
              appearance.iconSpacing = "small";
              appearance.rows.multirowView = "never";
              behavior.sortingMethod = "manually";
              behavior.grouping.method = "byProgramName";
              behavior.grouping.clickAction = "showTextualList";
              launchers = [
                # "preferred://browser" # does not behave well
                "applications:brave-browser.desktop"
                "applications:org.kde.dolphin.desktop"
                "applications:foot.desktop"
                "applications:thunderbird.desktop"
                "applications:org.keepassxc.KeePassXC.desktop"
              ];
            };
          }
          "org.kde.plasma.marginsseparator"
	  "org.kde.plasma.appmenu"
	  "org.kde.plasma.panelspacer"
          "org.kde.plasma.marginsseparator"
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
