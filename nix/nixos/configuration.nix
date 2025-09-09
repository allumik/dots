{ config, lib, pkgs, modulesPath, ... }:

let
  aretext = pkgs.buildGoModule rec {
    pname = "aretext";
    version = "1.5.0";

    src = pkgs.fetchFromGitHub {
      owner = "aretext";
      repo = "aretext";
      rev = "v${version}";
      sha256 = "sha256-pYU4wIrrVhGLyUKIsVBofxpsPyXvs1HIH/ioz9sTZ6I=";
    };

    vendorHash = "sha256-iLno+/raBA2u7c92FDP31DOw+vWAxgGpQgWWBr9HZs0=";

    # The project's Makefile uses the 'make' command.
    nativeBuildInputs = [ pkgs.gnumake ];

    ldflags = [ "-s" "-w" "-X main.version=${version}" ];

    meta = with pkgs.lib; {
      description = "A minimalist text editor with Vim-compatible bindings";
      homepage = "https://github.com/aretext/aretext";
      license = licenses.mit;
      platforms = platforms.all; # It can be compiled on more platforms now
    };
  };
in
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
    device = "/dev/disk/by-uuid/acbb7722-4b44-4a0a-9b66-44ad40318b0c";
    fsType = "ext4";
    options = [ "users" "nofail" "relatime" "x-gvfs-show" "exec" ];
  };

  ## add the swap partition
  swapDevices = [ { device = "/dev/nvme0n1p3"; } ]; # { device = "/dev/sdb2"; }
  boot.resumeDevice = "/dev/nvme0n1p3";

  networking.useDHCP = lib.mkDefault true;
  networking.hostName = "deskmeat"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;


  hardware = {
    enableAllFirmware = true;

    # Bluetooth settings
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = { General = { Enable = "Source, Sink, Media, Socket"; Experimental = true; }; Policy = { AutoEnable = true; }; };
    };

    # Graphics settings
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau-va-gl
        mesa
      ];
    };

    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    nvidia-container-toolkit.enable = true;

    keyboard.qmk.enable = true;

    nvidia = {
      # Modesetting is required.
      modesetting.enable = true;
  
      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      powerManagement.enable = true;
      powerManagement.finegrained = false;
  
      # Use the NVidia open source kernel module (not to be confused with the
      # independent third-party "nouveau" open source driver).
      open = false;
  
      # Enable the Nvidia settings menu, accessible via `nvidia-settings`.
      nvidiaSettings = true;
  
      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    openrazer.enable = true;
    openrazer.users = [ "allu" ];
  };

  nixpkgs = {
    hostPlatform = lib.mkDefault "x86_64-linux";
    config = {
      cudaSupport = true;
      allowUnfree = true;
    };
    ## Add overlays here for packages!
    overlays = [
      (final: prev: { conda = prev.conda.override { extraPkgs = [ prev.which ]; }; } )
    ];
  };



  #### Main
  ##

  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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
    };
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;
  };


  # Minimal Plasma 6 install by excluding some default packages
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    konsole oxygen kate elisa
  ];



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
      coreutils-full dnsutils pciutils findutils v4l-utils # util packages
      gnumake cmake gcc cargo rustc # compilers
      tlp auto-cpufreq # This is used for automatic power management
      libtool ethtool
      fwupd
      aretext
      fzf # file search metatool
      nnn # file system navigation and great speeds
      ripgrep # rg
      lnav # log file navigator and viewer
      parallel
      wget
      retry
      zip pigz unzip unrar p7zip # (de)compression
      plocate # faster locate
      nix-search-cli
      gitFull
      s-tui htop nvtopPackages.nvidia # sys info dashboards
      stress
      ffmpeg
      fdupes
      hd-idle # spin down HDD's after 10 min
      bluez-experimental
      pulseaudioFull

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
      conda # covers all computing env needs
      qmk
      dfu-programmer # qmk dep
      microscheme # qmk dep
      via # qmk dep

      # GUI
      syncthing
      veracrypt
      polychromatic # razer peripherals color control
      # digikam
      gparted
      kdePackages.kamera
      obs-studio
      vlc # general media player
      kdePackages.kcmutils
      kdePackages.flatpak-kcm
      kdePackages.phonon kdePackages.phonon-vlc
      kdePackages.kio-gdrive kdePackages.kio-fuse kdePackages.kio-extras

      # lutris setup for some games
      lutris
      wine-wayland
      winetricks
      wineWowPackages.waylandFull
      wineWowPackages.fonts

      # containers
      fuse3 fuse-overlayfs # fuse file system for containers
      qemu quickemu
      podman-desktop podman-tui podman-compose
      dive # look into docker image layers
      apptainer
      libnvidia-container # needed for apptainer --nvccli
      vmware-horizon-client
    ];
    sessionVariables = rec {
      # these are for the CUDA backend
      # CUDA_PATH = "${pkgs.cudaPackages.cudatoolkit}";
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

    # Enable sound with pipewire instead
    pulseaudio.enable = false;

    # Soundsystem
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.extraConfig.bluetoothEnhancements = {
        "monitor.bluez.properties" = {
            "bluez.enable-sbc-xq" = true;
            "bluez.enable-msbc" = true;
            "bluez.enable-hw-volume" = true; ### <<< Enables touch slider on headphones for fader gain, pause, and unpause functionality
            "bluez.auto-connect" = [ "a2dp_sink" ]; ### <<< Autoconnect to HD 48khz mode on connect
            "bluez.roles" = [ 
	      "a2dp_sink" 
	      "a2dp_source" 
              "hsp_hs"
              "hsp_ag"
              "hfp_hf"
              "hfp_ag"
	    ]; ### <<< This  sets the BT driver role to a2dp sink and source, which are the HD 44.1khz and 48khz module modesets but doesnt load the modules for hsp, which is the handset driver that enables the mic.
        };
      };
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

    # Enable fstrim for SSD's to TRIM stuff once a week
    # Check with `lsblk --discard` first if TRIM is enabled
    fstrim.enable = true;
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
  system.stateVersion = "25.05"; 
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true; # reboot when new kernel
}
