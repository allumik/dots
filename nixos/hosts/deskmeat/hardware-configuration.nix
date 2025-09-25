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

  # Kernel modules and initrd
  # https://github.com/chaotic-cx/nyx/issues/1178#issuecomment-3263837109
  boot.kernelPackages = pkgs.linuxPackages_cachyos-gcc; 
  services.scx.enable = true; # default scx_rustland, build issue on 250914
  services.scx.scheduler = "scx_bpfland"; # https://wiki.cachyos.org/configuration/sched-ext/
  services.scx.package = pkgs.scx.rustscheds; # so you don't use the full version for LAVD
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


  # Hardware Support
  chaotic.mesa-git.enable = true;
  hardware = {
    graphics.enable = true;
    # Try out Vulcan instead of the default Mesa, if bad, use mesa_git from chaotic
    # graphics.extraPackages = with pkgs; [ amdvlk ];   
    amdgpu.overdrive.enable = true;
    enableAllFirmware = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    keyboard.qmk.enable = true;
  };
}

