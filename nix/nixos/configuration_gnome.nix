{ config, lib, pkgs, modulesPath, ... }:

{
  #### hardware-configuration.nix
  ##
  ## edit it here, import but ignore the original one
  
  ## Still include the results from the hardware scan, just to be sure...
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./nvfancontrol.nix
      # include cachix for the crazy cuda compile
      ./cachix.nix
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # for kvm virtualisation
  boot.kernelModules = [ "kvm-amd" "dm-cache" "dm-cache-smq" "dm-persistent-data" "dm-bio-prison" "dm-clone" "dm-crypt" "dm-writecache" "dm-mirror" "dm-snapshot"];
  boot.extraModulePackages = [ ];
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-cache" "dm-cache-smq" "dm-cache-mq" "dm-cache-cleaner" ];
  # some fixes for malfunctioning kernel modules
  boot.blacklistedKernelModules = [
      "usci_ccg" # this seems to cause the graphics not turn on after sleep, disables the usbc on GPU (theres usbc there???)
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/fae35e59-edc7-41b1-9d8c-8cc5bead8d11";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/D63B-498A";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  ## load the big filesystem
  fileSystems."/mnt/data_main" = {
    device = "/dev/disk/by-uuid/5d552fd4-d414-4e35-ab2e-1fdcb2b59f74";
    fsType = "ext4";
    options = [ "users" "nofail" "x-gvfs-show" "exec" ];
  };

  ## add the swap partition
  swapDevices = [ { device = "/dev/nvme0n1p3"; } ]; # { device = "/dev/sdb2"; }
  boot.resumeDevice = "/dev/nvme0n1p3";

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  networking.hostName = "deskmeat"; # Define your hostname.
  networking.networkmanager.enable = true;
  # networking.interfaces.enp2s0.useDHCP = lib.mkDefault true;

  hardware = {
    # Graphics settings
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau-va-gl
        mesa.drivers
      ];
    };

    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    nvidia-container-toolkit.enable = true;

    keyboard.qmk.enable = true;

    nvidia = {
      # Modesetting is required.
      modesetting.enable = true;
  
      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      # Enable this if you have graphical corruption issues or application crashes after waking
      # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
      # of just the bare essentials.
      # Experimental and only works on modern Nvidia GPUs (Turing or newer).
      powerManagement.enable = true;
      powerManagement.finegrained = false;
  
      # Use the NVidia open source kernel module (not to be confused with the
      # independent third-party "nouveau" open source driver).
      # Support is limited to the Turing and later architectures. Full list of 
      # supported GPUs is at: 
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
      # Only available from driver 515.43.04+
      # Currently alpha-quality/buggy, so false is currently the recommended setting.
      open = false;
  
      # Enable the Nvidia settings menu,
      # accessible via `nvidia-settings`.
      nvidiaSettings = true;
  
      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };
  };

  nixpkgs = {
    hostPlatform = lib.mkDefault "x86_64-linux";
    config = {
      cudaSupport = true;
      allowUnfree = true;
    };
    overlays = [
      (final: prev: { conda = prev.conda.override { extraPkgs = [ prev.which ]; }; } )
    ];
  };

  #### Main
  ##

  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  hardware = {
    # Enable sound with pipewire.
    pulseaudio.enable = false;

    openrazer.enable = true;
    openrazer.users = [ "allu" ];
  };
  security.rtkit.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.UTF-8";
    LC_IDENTIFICATION = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8";
    LC_MONETARY = "nl_NL.UTF-8";
    LC_NAME = "nl_NL.UTF-8";
    LC_NUMERIC = "nl_NL.UTF-8";
    LC_PAPER = "nl_NL.UTF-8";
    LC_TELEPHONE = "nl_NL.UTF-8";
    LC_TIME = "nl_NL.UTF-8";
  };


  ### Desktop system for users - KDE
  services = {
    xserver = {
      enable = true;
      xkb.layout = "ee";
      xkb.variant = "us";
      videoDrivers = ["nvidia" "vmware"];
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
  };


  environment.gnome.excludePackages = (with pkgs; [
    epiphany # web browser
    evince # document viewer
    geary # email reader
    gedit # text editor
    gnome-characters
    gnome-music
    gnome-photos
    gnome-terminal
    gnome-tour
    atomix # puzzle game
    hitori # sudoku game
    iagno # go game
    tali # poker game
    totem # video player
  ]);


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.allu = {
    isNormalUser = true;  # dunno maan...
    description = "Alvin Meltsov";
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" "podman" ];
  };


  # List packages installed in system profile.
  environment = {
    systemPackages = with pkgs; [
      # core tools
      coreutils-full
      dnsutils
      pciutils
      findutils
      v4l-utils
      libtool
      gnumake
      cmake
      gcc
      auto-cpufreq # This is used for automatic power management
      fwupd
      tlp
      ethtool
      parallel
      wget
      zip
      p7zip
      plocate # faster locate
      nix-search-cli

      # convinience tools
      stress
      s-tui
      retry
      ffmpeg
      fdupes
      unzip
      unrar
      pigz
      ripgrep
      lnav
      htop
      nvtopPackages.nvidia
      # smartmontools # conflicts with hd-idle - spins up hdd every 30 min
      hd-idle
      fzf
      nnn
      gitFull
      conda

      # CUDA support, pytorch deps
      cudaPackages.cudatoolkit
      cudaPackages.cudnn
      cudaPackages.cutensor
      cudaPackages.nccl
      cudaPackages.cuda_opencl
      cudaPackages.cuda_cccl # <thrust/*>
      cudaPackages.cuda_cudart # cuda_runtime.h and libraries
      cudaPackages.cuda_cupti # For kineto
      cudaPackages.cuda_nvcc # crt/host_config.h;
      cudaPackages.cuda_nvml_dev # <nvml.h>
      cudaPackages.cuda_nvrtc
      cudaPackages.cuda_nvtx # -llibNVToolsExt
      cudaPackages.libcublas
      cudaPackages.libcufft
      cudaPackages.libcurand
      cudaPackages.libcusolver
      cudaPackages.libcusparse

      # some other tools
      tesseract # common OCR toolset
      openconnect # for VPN connections
      poppler
      poppler_utils
      lcdf-typetools
      wl-clipboard
      cargo
      rustc
      qmk
      dfu-programmer
      microscheme
      via

      # graphical stuff
      vmware-horizon-client
      syncthing
      polychromatic
      gparted
      obs-studio
      furmark
      veracrypt
      vlc
      gnome-tweaks
      dconf-editor
      gnome-extension-manager
      gnome-extensions-cli

      # lutris setup for some games
      lutris
      wine-wayland
      winetricks
      wineWowPackages.waylandFull
      wineWowPackages.fonts

      # containers
      qemu
      quickemu
      dive # look into docker image layers
      podman-desktop
      podman-tui # status of containers in the terminal
      podman-compose # start group of containers for de
      apptainer
      libnvidia-container # needed for apptainer --nvccli
      fuse3
      fuse-overlayfs
    ];
    sessionVariables = rec {
      # these are for the CUDA backend
      CUDA_PATH = "${pkgs.cudaPackages.cudatoolkit}";
      EXTRA_LDFLAGS = "-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib";
      EXTRA_CCFLAGS = "-I/usr/include";
    }; 
  };

  programs = {
    # this is useful for getting some binaries to work, ie vscode extensions or micromamba
    nix-ld.enable = true;

    # Some programs need SUID wrappers, can be configured further or are started in user sessions.
    mtr.enable = true;

    steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    };

    java.enable = true;

    neovim = {
      enable = true;
      defaultEditor = true;
    };

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    # this also applies for apptainer
    singularity.enable = true;

    virt-manager.enable = true;
  };
 

  virtualisation = {
    containers.enable = true;
    oci-containers.backend = "podman";
    podman = {
      enable = true;
      autoPrune.enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };

    # Add KVM for good linux virt support
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [(pkgs.OVMF.override {
            secureBoot = true;
            tpmSupport = true;
      	  }).fd];
        };
      };
    };

    spiceUSBRedirection.enable = true;
    vmware.guest.enable = true;
  };


  ### List (other) services that you want to enable:
  services = {
    # Enable the OpenSSH daemon.
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };

    # Enable CUPS to print documents.
    printing.enable = true;

    # Soundsystem
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    # not very pure, but sometimes is needed to get the work done...
    flatpak.enable = true;

    # make the "cache_check" warning dissapear
    lvm.boot.thin.enable = true;

    # When running NixOS as a guest, enable the QEMU guest agent
    qemuGuest.enable = true;
    spice-vdagentd.enable = true;

    # use this for managing qmk devices
    udev.packages = [ pkgs.via ];
  };

  # spinoff any rotating drives after idle for 10m|600s
  systemd.services.hd-idle = {
    description = "External HD spin down daemon";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.hd-idle}/bin/hd-idle -i 600";
    };
  };



  ### Misc
  # Do some automatic garbage collection and delete old snaps
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
  system.autoUpgrade.enable = true;
  # system.autoUpgrade.allowReboot = true;
}
