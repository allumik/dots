# This file contains hardware-specific settings for the 'deskmeat' host.
# It is intended to be edited by hand.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # Nixpkgs platform
  nixpkgs.hostPlatform = "x86_64-linux";

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.useOSProber = true;

  # Kernel modules and initrd
  boot.kernelPackages = pkgs.linuxPackages_latest; # not working well with wifi
  services.scx.enable = true; # default scx_rustland, build issue on 250914
  services.scx.scheduler = "scx_bpfland"; # https://wiki.cachyos.org/configuration/sched-ext/

  boot.kernelModules = [ 
    # AMD GPU and CPU related, keep dm-crypt for encrypted drives
    "amdgpu" "kvm-amd" "dm-crypt"
  ];
  boot.blacklistedKernelModules = [ "r8169" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.r8168 ];
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "usbhid" "sd_mod" ]; 
  # Force the r8168 driver to allow waking from an S5 powered-off state
  boot.extraModprobeConfig = ''
    options r8168 s5wol=1
  '';


  # Filesystems and Swap
  fileSystems."/" = { device = "/dev/disk/by-uuid/fae35e59-edc7-41b1-9d8c-8cc5bead8d11"; fsType = "ext4"; };
  fileSystems."/boot" = { device = "/dev/disk/by-uuid/D63B-498A"; fsType = "vfat"; options = [ "fmask=0022" "dmask=0022" ]; };

  # Primary SATA Storage (SD Ultra 3D)
  fileSystems."/mnt/data_main" = { 
    device = "/dev/disk/by-uuid/f0b1c5e8-5227-44d3-bd01-ec7b7b655205"; 
    fsType = "ext4"; 
    options = [ "users" "nofail" "relatime" "x-gvfs-show" "exec" ]; 
  };

  # USB Header Storage (Crucial BX500)
  fileSystems."/mnt/data_usb" = { 
    device = "/dev/disk/by-uuid/00c47e7d-748e-4cf8-b6f7-0a1dd14b9fdc"; 
    fsType = "ext4"; 
    options = [ "users" "nofail" "relatime" "x-gvfs-show" "exec" ]; 
  };
  # and mark it as not removable, so that we don't remove it by accident
  services.udev.extraRules = ''
    # Hide USB header drive from removable media applets
    SUBSYSTEM=="block", ENV{ID_FS_UUID}=="00c47e7d-748e-4cf8-b6f7-0a1dd14b9fdc", ENV{UDISKS_IGNORE}="1"
  '';

  swapDevices = [ { device = "/dev/nvme0n1p3"; } ];
  boot.resumeDevice = "/dev/nvme0n1p3";
  boot.kernel.sysctl = { "vm.swappiness" = 10; }; # lower it from 60 as we have loads of RAM
  # Enable zramSwap only in RAM compression for large memory loads, defaults are: 50% RAM; zstd
  boot.kernelParams = [
    "zswap.enabled=1" # enables zswap
    "zswap.max_pool_percent=50" # maximum percentage of RAM that zswap is allowed to use
    "zswap.shrinker_enabled=1" # whether to shrink the pool proactively on high memory pressure
    "zswap.zpool=zsmalloc"
    "iwlwifi.disable_11ax=0"
    "iwlwifi.uapsd_disable=1"  # Disable U-APSD to improve stability on some APs
    "usbcore.autosuspend=-1"
  ];


  # Hardware Support
  hardware = {
    graphics = { 
      enable = true;
      package = pkgs.mesa;  
      extraPackages = with pkgs; [
	rocmPackages.clr
	rocmPackages.clr.icd
      ];
    };
    amdgpu.overdrive.enable = true;
    enableAllFirmware = true;
    keyboard.qmk.enable = true;
    bluetooth = {
      enable = true;
      settings = { General = { Enable = "Source, Sink, Media, Socket"; Experimental = true; }; Policy = { AutoEnable = true; }; };
    };
    # More misc hardware-related software
    openrazer = {
      enable = true;
      users = [ "allu" ];
    };
  };
}

