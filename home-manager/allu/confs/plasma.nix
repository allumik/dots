{ config, pkgs, ... }:

{
  imports = [<plasma-manager/modules>];

  programs.plasma = {
    enable = true; # enable and configure plasma settings
    overrideConfig = true; # default all else

    workspace = {
      theme = "commonalitysol";
      lookAndFeel = "org.magpie.commsol.desktop"; # not used with windowDecor
      iconTheme = "Memphis98";
      cursor = {
        size = 24;
        theme = "Bibata-Modern-Ice";
      };
      clickItemTo = "select";
      wallpaper = ./wall331.png;
      wallpaperFillMode = "preserveAspectCrop"; # pad
      wallpaperBackground.color = "44,81,80"; # R,G,B
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
      kwin = {
        "Grid View" = "Meta+Tab";
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
      titlebarButtons.left = [ "more-window-actions" "keep-above-windows" ];
      titlebarButtons.right = [ "help" "minimize" "maximize" "close" ];
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

    powerdevil.general.pausePlayersOnSuspend = false;
    powerdevil.AC = {
      autoSuspend.action = "sleep";
      autoSuspend.idleTimeout = 10800; # 3h until sleeps
      dimDisplay.enable = true;
      dimDisplay.idleTimeout = 720;
      turnOffDisplay.idleTimeout = 900;
      powerButtonAction = "sleep";
      powerProfile = "performance";
    };


    # check out examples in https://github.com/nix-community/plasma-manager/blob/trunk/examples/home.nix
    # Here I have a simple vertical Windows style panel with a app launcher, manager, systray and a clock
    panels = [
      { 
        location = "left";
        alignment = "center";
        floating = false;
        height = 36; # different screens, different resolutions...
        hiding = "normalpanel";
        lengthMode = "fill";
        opacity = "opaque";
        widgets = [
          {
            kicker = {
              behavior.sortAlphabetically = false;
              behavior.flattenCategories = false;
              behavior.showIconsOnRootLevel = false;
              categories.show.recentApplications = true;
              categories.show.recentFiles = true;
              categories.order = "recentFirst";
              search.alignResultsToBottom = true;
              search.expandSearchResults = true;
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
          "org.kde.plasma.systemtray"
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.analogclock"
        ];
      }
    ];

    # TODO: tiling presets with polonium
  };
}
