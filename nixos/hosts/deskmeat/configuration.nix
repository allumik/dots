# hosts/deskmeat/configuration.nix
{ config, lib, pkgs, ... }:

{
  ## Imports
  imports = [
    ../base.nix # Minimal conf
    ../common.nix # Common configuration options for all hosts
    ./hardware-configuration.nix # Hardware-specific configuration
    ./system-packages.nix
    ./users.nix
  ];


  ## Networking
  networking.hostName = "deskmeat";
  networking.networkmanager = {
    enable = true;
    wifi.powersave = false; # set it to false just to be sure that it works
    plugins = with pkgs; [ networkmanager-openvpn networkmanager-openconnect ];
  };


  ## Program Settings and Services
  security.rtkit.enable = true;
  services = {
    xserver.videoDrivers = [ "amdgpu" "vmware"]; # Xorg video drivers for this host
    fstrim.enable = true; # To trim SSD blocks
    flatpak.enable = true;
    lvm.boot.thin.enable = true;
    qemuGuest.enable = true; # Enable QEMU
    spice-vdagentd.enable = true; # Necessary for the QEMU spice
    udev.packages = [ pkgs.via ]; # Set up VIA for QMK shenigans
    lact.enable = true; # Manage your GPU from 25.11 onward
    tailscale.enable = true;
    pcscd = {
      enable = true; # smard card reader support
      plugins = [ pkgs.ccid ];
    };
  };
  virtualisation = {
    containers.enable = true;
    oci-containers.backend = "podman";
    podman = {
      enable = true;
      autoPrune.enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true; # Enable USB devices connecting to QEMU spice
    vmware.guest.enable = true;
  };
}
