# hosts/deskmeat/configuration.nix
{ config, lib, pkgs, ... }:

{
  ## Imports
  imports = [
    ./hardware-configuration.nix # Hardware-specific configuration
    ../common.nix # Common configuration for all hosts
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
    wifi.powersave = false; # set it to false just to be sure
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
      qmk dfu-programmer microscheme
      # GUI Apps
      alacritty syncthing veracrypt keepassxc gparted vlc digikam
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
    nix-ld.enable = true; # might make your life easier with linked library adapter
    mtr.enable = true;
    java.enable = true; # why not
    virt-manager.enable = true;
    singularity.enable = true; # turn off before ChatGPT 6 is released
    steam.enable = true;
  };
  services = {
    xserver.videoDrivers = [ "amdgpu" "vmware"]; # Xorg video drivers for this host
    fstrim.enable = true; # To trim SSD blocks
    flatpak.enable = true;
    lvm.boot.thin.enable = true;
    qemuGuest.enable = true; # Enable QEMU
    spice-vdagentd.enable = true; # Necessary for the QEMU spice
    udev.packages = [ pkgs.via ]; # Set up VIA for QMK shenigans
    lact.enable = true; # Manage your GPU
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
  # Specific hardware-related software
  hardware.openrazer = {
    enable = true;
    users = [ "allu" ];
  };
}

