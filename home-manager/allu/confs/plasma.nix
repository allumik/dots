{ config, pkgs, ... }:

{
  imports = [<plasma-manager/modules>];

  programs.plasma = {
    enable = true; # enable and configure plasma settings
    
    input.keyboard = {
      repeatDelay = 280;
      repeatRate = 40;
    };

    powerdevil.general.pausePlayerOnSuspend = false;
    powerdevil.AC = {
      autoSuspend.action = "sleep";
      autoSuspend.idleTimeout = 10800; # 3h until sleeps
      dimDisplay.enable = true;
      dimDisplay.idleTimeout = 720;
      turnOffDisplay.idleTimeout = 900;
      powerButtonAction = "sleep";
      powerProfile = "performance";
    };

    kwin = {
      virtualDesktop.names = [ "Main" "Additional" ];
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

    fonts = {
      general = { family = "Noto Sans"; pointSize = 10; };
      fixedWidth = { family = "Iosevka Term SS08"; pointSize = 10; };
      small = { family = "Noto Sans"; pointSize = 8; };
      toolbar = { family = "Noto Sans"; pointSize = 10; };
      menu = { family = "Noto Sans"; pointSize = 10; };
      windowTitle = { family = "Fixedsys Excelsior 3.01"; pointSize = 11; };
    };

    workspace = {
      theme = "commonality";
      lookAndFeel = "org.magpie.comm.desktop";
      iconTheme = "Memphis98";
      cursor = {
        size = 24;
        theme = "Bibata-Modern-Ice";
      };
      clickItemTo = "select";
    };

    # TODO: panels 
  };
};
