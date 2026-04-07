# hosts/oldlenno/configuration.nix
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
  networking.hostName = "oldlenno";
  networking.networkmanager = {
    enable = true;
    wifi.powersave = false; # set it to false just to be sure that it works
    ethernet.macAddress = "stable";
    plugins = with pkgs; [ networkmanager-openvpn networkmanager-openconnect ];
  };


  ## Program Settings and Services
  security.rtkit.enable = true;
  services = {
    xserver.videoDrivers = [ "vmware"]; # Xorg video drivers for this host
    fstrim.enable = true; # To trim SSD blocks
    flatpak.enable = true;
    lvm.boot.thin.enable = true;
    qemuGuest.enable = true; # Enable QEMU
    spice-vdagentd.enable = true; # Necessary for the QEMU spice
    udev.packages = [ pkgs.via ]; # Set up VIA for QMK shenigans
    openssh.enable = true;
    tailscale.enable = true;
    pcscd = { 
      enable = true; # smard card reader support
      plugins = [ pkgs.ccid ];
    };
    # keep running unless shut down manually
    logind.settings.Login.extraConfig = ''
      IdleAction=ignore
      HandleLidSwitch=ignore
    '';
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
