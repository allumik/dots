# hosts/deskmeat/configuration.nix
{ config, lib, pkgs, ... }:

{
  ## Imports
  imports = [
    # Hardware-specific configuration
    ./hardware-configuration.nix
    # Common configuration for all hosts
    ../common.nix # this loads base.nix by itself
  ];

  ## User accounts
  users.users.allu = {
    isNormalUser = true;
    description = "Alvin Meltsov";
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" "podman" ];
  };


  ## Networking
  networking.hostName = "deskmeat";
  networking.networkmanager = {
    enable = true;
    # set it to false just to be sure that we are not disconnecting unnecessarily
    wifi.powersave = false;
    plugins = with pkgs; [
      networkmanager-openvpn
      networkmanager-openconnect
    ];
  };


  ## System-wide packages and variables for this host
  # Add ROCm support for nixpkgs
  nixpkgs.config.rocmSupport = true;
  environment = {
    systemPackages = with pkgs; [
      # Other Tools
      tesseract openconnect openvpn poppler poppler_utils wl-clipboard 
      qmk dfu-programmer microscheme via
      # GUI Apps
      alacritty syncthing veracrypt keepassxc gparted vlc lact
      kdePackages.kcmutils kdePackages.flatpak-kcm kdePackages.phonon kdePackages.phonon-vlc 
      kdePackages.kio-gdrive kdePackages.kio-fuse kdePackages.kamera kdePackages.kio-extras
      # Gaming
      lutris protonup-qt wine-wayland winetricks wineWowPackages.waylandFull wineWowPackages.fonts
      # Containers
      fuse3 fuse-overlayfs qemu quickemu podman-desktop podman-tui podman-compose apptainer 
      omnissa-horizon-client
      # AMD ROCm thingies
      rocmPackages.amdsmi rocmPackages.rocm-core rocmPackages.clr rocmPackages.mpi 
      rocmPackages.rocm-device-libs rocmPackages.hipblaslt rocmPackages.tensile
      # LLM runner, built for ROCm
      ollama-rocm
    ];
  };


  ## Program Settings and Services
  security.rtkit.enable = true;
  programs = {
    nix-ld.enable = true;
    mtr.enable = true;
    steam.enable = true;
    java.enable = true;
    singularity.enable = true;
    virt-manager.enable = true;
  };
  services = {
    # Xorg video drivers for this host
    xserver.videoDrivers = [ "amdgpu" "vmware"];
    printing.enable = true;
    flatpak.enable = true;
    lvm.boot.thin.enable = true;
    qemuGuest.enable = true;
    spice-vdagentd.enable = true;
    udev.packages = [ pkgs.via ];
    fstrim.enable = true;
    lact.enable = true;
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
  # Specific hardware-related software
  hardware.openrazer = {
    enable = true;
    users = [ "allu" ];
  };
}

