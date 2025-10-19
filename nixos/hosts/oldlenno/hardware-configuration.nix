# This file contains hardware-specific settings for the 'oldlenno' host.
# It is intended to be edited by hand.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # Nixpkgs platform
  nixpkgs.hostPlatform = "x86_64-linux";

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel modules and initrd
  # specify the kernel package - use the default for the old intel cpu
  boot.kernelPackages = pkgs.linuxPackages_latest;
  services.scx.enable = true; # default scx_rustland, build issue on 250914
  services.scx.scheduler = "scx_bpfland"; # https://wiki.cachyos.org/configuration/sched-ext/
  services.scx.package = pkgs.scx.rustscheds; # so you don't use the full version for LAVD

  # Intel GPU and CPU related
  boot.kernelModules = [ "kvm-intel"  ];
  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "sr_mod" "rtsx_pci_sdmmc" ]; 
  boot.initrd.kernelModules = [ ];


  # Filesystems and Swap
  boot.initrd.luks.devices."luks-de8b828a-b902-4b08-aa80-9786c15a0c4d".device = "/dev/disk/by-uuid/de8b828a-b902-4b08-aa80-9786c15a0c4d";
  boot.initrd.luks.devices."luks-d12d5ae9-f3e4-4913-b0ff-418d17973d24".device = "/dev/disk/by-uuid/d12d5ae9-f3e4-4913-b0ff-418d17973d24";

  fileSystems."/" = { 
    device = "/dev/disk/by-uuid/ae45eedd-75bd-4795-b2ea-21fbbb84b89a"; 
    fsType = "ext4"; 
    };
  fileSystems."/boot" = { 
    device = "/dev/disk/by-uuid/EEEC-31D4"; 
    fsType = "vfat"; 
    options = [ "fmask=0077" "dmask=0077" ]; 
    };
  swapDevices = [ { device = "/dev/disk/by-uuid/2d83e3ce-fbfb-4be6-a504-6192f9b892e2"; } ];

  # # The additional WDC disk
  # fileSystems."/mnt/data_main" =
  #   { device = "/dev/disk/by-uuid/0d138368-93b0-46da-877d-19917dd74047";
  #     fsType = "ext4";
  #   };


  # Hardware Support
  hardware = {
    enableAllFirmware = true;
    graphics = { 
      enable = true;
      package = pkgs.mesa;  
    };
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    keyboard.qmk.enable = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };
}

