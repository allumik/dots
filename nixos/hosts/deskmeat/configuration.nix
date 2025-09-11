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


  ## Networking
  networking.hostName = "deskmeat";
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;


  ## User accounts
  users.users.allu = {
    isNormalUser = true;
    description = "Alvin Meltsov";
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" "podman" ];
  };


  ## System-wide packages and variables for this host
  environment = {
    systemPackages = with pkgs; [
      # Other Tools
      tesseract openconnect poppler poppler_utils lcdf-typetools wl-clipboard conda qmk dfu-programmer microscheme via
      # AMD ROCm thingies
      rocmPackages.clr rocmPackages.mpi rocmPackages.rocm-core rocmPackages.rocm-device-libs python313Packages.torchWithRocm
      # GUI Apps
      alacritty syncthing veracrypt polychromatic gparted kdePackages.kamera obs-studio vlc lact
      kdePackages.kcmutils kdePackages.flatpak-kcm kdePackages.phonon kdePackages.phonon-vlc kdePackages.kio-gdrive kdePackages.kio-fuse kdePackages.kio-extras
      # Gaming
      lutris wine-wayland winetricks wineWowPackages.waylandFull wineWowPackages.fonts proton-cachyos_x86_64_v4	
      # Containers
      fuse3 fuse-overlayfs qemu quickemu podman-desktop podman-tui podman-compose apptainer omnissa-horizon-client
      # LLM runner
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
    lact.enable = true; # AMD GPU tuning daemon
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


  ## Extras
  # LACT - AMD GPU settings dashboard
  systemd = {
    packages = with pkgs; [ lact ];
    services.lact.enable = true;
    services.lact.wantedBy = [ "multi-user.target" ];
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

