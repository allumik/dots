{ config, lib, pkgs, ... }:

{
  ## User accounts
  users.users.allu = {
    isNormalUser = true; # dunno man
    description = "Alvin Meltsov";
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" "podman" ];
  };
  home-manager.users.allu = {
    imports = [
      ../../users/allu/home.nix
      ../../users/allu/plasma.nix # Plasma
    ];
    programs = {
      brave = {
        enable = true;
        commandLineArgs = [ "--ozone-platform=wayland" ];
        nativeMessagingHosts = [ pkgs.kdePackages.plasma-browser-integration ];
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

      # set it to run constatntly
      plasma = {
        powerdevil = {
	  general.pausePlayersOnSuspend = false;
	  AC = {
            autoSuspend.action = null;
            dimDisplay.enable = true;
            dimDisplay.idleTimeout = 720;
            turnOffDisplay.idleTimeout = 900;
	    inhibitLidActionWhenExternalMonitorConnected = true;
	    powerProfile = "performance";
	    powerButtonAction = "lockScreen";
          };
          battery = {
            autoSuspend.action = null;
            dimDisplay.enable = true;
            dimDisplay.idleTimeout = 720;
            turnOffDisplay.idleTimeout = 900;
	    powerProfile = "powerSaving";
	    powerButtonAction = "lockScreen";
          };
        };
  
        # Independent configuration for session security
        kscreenlocker = {
          autoLock = true;
          timeout = 5;
          lockOnResume = true;
        };
      };
    };
  };
}
