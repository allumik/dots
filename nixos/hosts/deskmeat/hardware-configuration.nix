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
  boot.kernelPackages = pkgs.linuxPackages_zen;
  services.scx.enable = true; # default scx_rustland, build issue on 250914
  services.scx.scheduler = "scx_bpfland"; # https://wiki.cachyos.org/configuration/sched-ext/

  boot.kernelModules = [ 
    # AMD GPU and CPU related
    "amdgpu" "kvm-amd"  
    # used for logical volumes, cache's might be useless now if not using lvm-cache anymore
    "dm-cache" "dm-cache-smq" "dm-bio-prison" "dm-writecache"  
    # used for mounting LVM volumes
    "dm-persistent-data" "dm-mirror" "dm-clone" "dm-crypt" "dm-snapshot"  
  ];
  # don't know why they are here
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "usbhid" "sd_mod" ]; 
  # also used for mounting LVM volumes
  boot.initrd.kernelModules = [ "dm-cache" "dm-cache-smq" "dm-cache-mq" "dm-cache-cleaner" ];


  # Filesystems and Swap
  fileSystems."/" = { device = "/dev/disk/by-uuid/fae35e59-edc7-41b1-9d8c-8cc5bead8d11"; fsType = "ext4"; };
  fileSystems."/boot" = { device = "/dev/disk/by-uuid/D63B-498A"; fsType = "vfat"; options = [ "fmask=0022" "dmask=0022" ]; };
  fileSystems."/mnt/data_main" = { device = "/dev/disk/by-uuid/acbb7722-4b44-4a0a-9b66-44ad40318b0c"; fsType = "ext4"; options = [ "users" "nofail" "relatime" "x-gvfs-show" "exec" ]; };

  swapDevices = [ { device = "/dev/nvme0n1p3"; } ];
  boot.resumeDevice = "/dev/nvme0n1p3";
  boot.kernel.sysctl = { "vm.swappiness" = 10; }; # lower it from 60 as we have loads of RAM
  # Enable zram in RAM compression for large memory loads, defaults are: 50% RAM; zstd
  zramSwap = {
    enable = true;
    memoryPercent = 75;
  };

  # Hardware Support
  hardware = {
    graphics = { 
      enable = true;
      package = pkgs.mesa;  
    };
    amdgpu.overdrive.enable = true;
    enableAllFirmware = true;
    keyboard.qmk.enable = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = { General = { Enable = "Source, Sink, Media, Socket"; Experimental = true; }; Policy = { AutoEnable = true; }; };
    };
  };
}

