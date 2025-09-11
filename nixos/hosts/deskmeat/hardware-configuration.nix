# This file contains hardware-specific settings for the 'deskmeat' host.
# It is intended to be edited by hand.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel modules and initrd
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPackages = pkgs.linuxPackages_cachyos-gcc.cachyOverride { mArch = "ZEN4"; }; #https://github.com/chaotic-cx/nyx/issues/1178#issuecomment-3263837109
  services.scx.enable = true; # by default uses scx_rustland scheduler
  boot.kernelModules = [ "amdgpu" "kvm-amd" ];
  # boot.blacklistedKernelModules = [ "usci_ccg" ];

  # Filesystems and Swap
  fileSystems."/" = { device = "/dev/disk/by-uuid/fae35e59-edc7-41b1-9d8c-8cc5bead8d11"; fsType = "ext4"; };
  fileSystems."/boot" = { device = "/dev/disk/by-uuid/D63B-498A"; fsType = "vfat"; options = [ "fmask=0022" "dmask=0022" ]; };
  fileSystems."/mnt/data_main" = { device = "/dev/disk/by-uuid/acbb7722-4b44-4a0a-9b66-44ad40318b0c"; fsType = "ext4"; options = [ "users" "nofail" "relatime" "x-gvfs-show" "exec" ]; };

  swapDevices = [ { device = "/dev/nvme0n1p3"; } ];
  boot.resumeDevice = "/dev/nvme0n1p3";

  # Nixpkgs platform
  nixpkgs.hostPlatform = "x86_64-linux";

  # Hardware Support
  hardware = {
    graphics.enable = true;
    amdgpu.overdrive.enable = true;
    enableAllFirmware = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    keyboard.qmk.enable = true;
  };
}

