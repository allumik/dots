# hosts/deskmeat/configuration.nix
{ config, lib, pkgs, ... }:

{
  imports = [
    # Hardware-specific configuration
    ./hardware-configuration.nix
    # NVidia fan control script
    ./nvfancontrol.nix
    # Common configuration for all hosts
    ../common.nix
  ];

  # Networking
  networking.hostName = "deskmeat";
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;

  # Specific hardware-related software
  hardware.openrazer = {
    enable = true;
    users = [ "allu" ];
  };

  # User-specific settings for this host
  users.users.allu.extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" "podman" ];

  # Xorg video drivers for this host
  services.xserver.videoDrivers = ["nvidia" "vmware"];

  # System-wide packages for this host
  environment.systemPackages = with pkgs; [
    # Other Tools
    tesseract openconnect poppler poppler_utils lcdf-typetools wl-clipboard conda qmk dfu-programmer microscheme via
    # GUI Apps
    syncthing veracrypt polychromatic gparted kdePackages.kamera obs-studio vlc
    kdePackages.kcmutils kdePackages.flatpak-kcm kdePackages.phonon kdePackages.phonon-vlc kdePackages.kio-gdrive kdePackages.kio-fuse kdePackages.kio-extras
    # Gaming
    lutris wine-wayland winetricks wineWowPackages.waylandFull wineWowPackages.fonts
    # Containers
    fuse3 fuse-overlayfs qemu quickemu podman-desktop podman-tui podman-compose dive apptainer libnvidia-container vmware-horizon-client
  ];

  environment.sessionVariables = {
    EXTRA_CCFLAGS = "-I/usr/include";
  };

  # Programs and Services
  security.rtkit.enable = true;
  programs = {
    nix-ld.enable = true;
    mtr.enable = true;
    steam.enable = true;
    java.enable = true;
    singularity.enable = true;
    virt-manager.enable = true;
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
    spiceUSBRedirection.enable = true;
    vmware.guest.enable = true;
  };
  services = {
    printing.enable = true;
    flatpak.enable = true;
    lvm.boot.thin.enable = true;
    qemuGuest.enable = true;
    spice-vdagentd.enable = true;
    udev.packages = [ pkgs.via ];
    fstrim.enable = true;
  };

  # Spin down HDDs after 10 minutes
  systemd.services.hd-idle = {
    description = "External HD spin down daemon";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.hd-idle}/bin/hd-idle -i 600";
    };
  };
}

