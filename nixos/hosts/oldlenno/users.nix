{ config, lib, pkgs, ... }:

{
  ## User accounts
  users.users.allu = {
    isNormalUser = true; # dunno man
    description = "Alvin Meltsov";
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" "podman" ];
  };
  # brave/foot/syncthing/etc. are all configured in users/allu/confs/desktop.nix
  # and theme.nix - this used to also carry Plasma-specific power/lock config
  # (programs.plasma.powerdevil/kscreenlocker) from when this host ran Plasma,
  # which doesn't apply to niri and doesn't exist without plasma-manager imported.
  home-manager.users.allu = {
    imports = [ ../../users/allu/home.nix ];
  };
}
