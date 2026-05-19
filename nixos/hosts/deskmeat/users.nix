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
      imports = [ ../../users/allu/home.nix ];
    };
  };
}
