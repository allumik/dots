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
    };
    services = {
      syncthing = {
        enable = true;
        tray.enable = true;
      };
    };
  };
}
