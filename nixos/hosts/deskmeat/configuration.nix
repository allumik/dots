# hosts/deskmeat/configuration.nix
{ config, lib, pkgs, ... }:

{
  ## Imports
  imports = [
    ../base.nix # Minimal conf
    ../common.nix # Common configuration options for all hosts
    ../stylix.nix # Unified GTK/Qt/fuzzel/waybar theming
    ./hardware-configuration.nix # Hardware-specific configuration
    ./system-packages.nix
    ./users.nix
  ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1";


  ## Networking
  networking.hostName = "deskmeat";
  # Trust the Tailscale interface in the firewall
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  # Wake-on-LAN Configuration
  networking.interfaces.enp2s0.wakeOnLan.enable = true;
  networking.firewall.allowedUDPPorts = [ 9 ];
  networking.networkmanager = {
    enable = true;
    wifi.powersave = false; # set it to false just to be sure that it works
    plugins = with pkgs; [ networkmanager-openvpn networkmanager-openconnect ];
  };
  # Prevent network interfaces from restarting during nixos-rebuild switch
  systemd.services.NetworkManager.restartIfChanged = false;
  systemd.services.tailscaled.restartIfChanged = false;


  ## Program Settings and Services
  programs = {
    niri.enable = true;
  };

  security.rtkit.enable = true; # realtime scheduling for pipewire

  services = {
    xserver.videoDrivers = [ "amdgpu" "vmware"]; # Xorg video drivers for this host
    fstrim.enable = true; # To trim SSD blocks
    flatpak.enable = true;
    lvm.boot.thin.enable = true;
    qemuGuest.enable = true; # Enable QEMU
    spice-vdagentd.enable = true; # Necessary for the QEMU spice
    lact.enable = true; # Manage your GPU from 25.11 onward
    tailscale = {
      enable = true;
      # extraUpFlags = [ "--ssh" ];
    };
    pcscd = {
      enable = true; # smard card reader support
      plugins = [ pkgs.ccid ];
    };
    # login manager
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd ${config.programs.niri.package}/bin/niri-session";
          user = "greeter";
        };
      };
    };
    gnome.gnome-keyring.enable = true; # secret service
  };

  # NixOS otherwise injects a stripped PATH via Environment= on the niri.service
  # unit which shadows the imported user-manager PATH. Disabling the default
  # lets niri inherit the full PATH set up by niri-session.
  systemd.user.services.niri.enableDefaultPath = false;

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
