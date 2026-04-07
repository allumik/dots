{ config, lib, pkgs, ... }:

{
  ## User accounts
  users.users.allu = {
    isNormalUser = true; # dunno man
    description = "Alvin Meltsov";
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" "podman" ];
  };
  home-manager.users = {
    # Add other users here

    allu = {
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
      };
      services = {
        syncthing = {
          enable = true;
          tray.enable = true;
        };
      };

      # power configuration for user
      plasma = {
    	powerdevil.general.pausePlayersOnSuspend = false;
        powerdevil.AC = {
          autoSuspend.action = "sleep";
          autoSuspend.idleTimeout = 10800; # 3h until sleeps
          dimDisplay.enable = true;
          dimDisplay.idleTimeout = 720;
          turnOffDisplay.idleTimeout = 900;
	  powerProfile = "performance";
	  powerButtonAction = "sleep";
        };
	# no need for battery management, does not have one
  
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
