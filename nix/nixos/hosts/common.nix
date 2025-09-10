# hosts/common.nix
# Common settings for all hosts
{ config, pkgs, ... }:

{
  imports = [
    # The minimal base configuration
    ./base.nix
  ];

  # Nixpkgs configuration for all hosts
  nixpkgs.config = {
    cudaSupport = true;
    allowUnfree = true;
  };

  # Core packages and services
  environment.systemPackages = with pkgs; [
    # Utilities
    coreutils-full dnsutils pciutils v4l-utils findutils libtool ethtool fwupd hd-idle
    # Development & Build
    gnumake cmake gcc cargo rustc tlp auto-cpufreq
    # CLI Tools
    lnav parallel retry pigz unrar plocate nix-search-cli gitFull
    # Monitoring
    s-tui stress htop nvtopPackages.nvidia
    # Media & Files
    ffmpeg fdupes bluez-experimental pulseaudioFull
  ];

  # Enable some core programs
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };


  # Default user account
  users.users.allu = {
    isNormalUser = true;
    description = "Alvin Meltsov";
  };

  # Minimal Plasma 6 install by excluding some default packages
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    konsole oxygen kate elisa
  ];

  ### Desktop system settings
  services = {
    # We are running Plasma 6 now, so use SDDM and Plasma 6
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;

    # Sound System
    pulseaudio.enable = false; # Disable pulseaudio in favor of pipewire
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
            "bluez.enable-hw-volume" = true;
            "bluez.auto-connect" = [ "a2dp_sink" ];
            "bluez.roles" = [ "a2dp_sink" "a2dp_source" "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
        };
      };
    };
  };
}

