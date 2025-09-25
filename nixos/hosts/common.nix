# hosts/common.nix
# Common settings with all the bells and tools for all hosts
{ config, pkgs, ... }:

{
  imports = [ ./base.nix ];

  ## Nixpkgs coniguration for all hosts
  nixpkgs.config.allowUnfree = true;


  ## Core packages and services
  environment.systemPackages = with pkgs; [
    # Utilities
    coreutils-full dnsutils pciutils v4l-utils findutils libtool ethtool fwupd hd-idle cachix
    # Development & Build
    gnumake cmake gcc cargo rustc tlp auto-cpufreq
    # Default terminal
    alacritty 
    # CLI Tools
    lnav parallel retry pigz unrar plocate nix-search-cli gitFull
    # Monitoring
    s-tui stress htop
    # Media & Files
    vlc ffmpeg fdupes bluez-experimental pulseaudioFull
  ];
  fonts.packages = with pkgs; [
    # Font packs
    unifont corefonts vistafonts noto-fonts 
    # Pretty symbol packs, often used as fallback symbols
    font-awesome material-icons powerline-symbols
    # Some fonts I really like
    iosevka ibm-plex vt323 fixedsys-excelsior
  ];


  ## Desktop system settings
  # Minimal Plasma 6 install by excluding some default packages
  environment.plasma6.excludePackages = with pkgs.kdePackages; [ konsole oxygen kate elisa ];
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

  ## Extras
  systemd.services = {
    # Spin down HDDs after 10 minutes
    hd-idle = {
      description = "External HD spin down daemon";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.hd-idle}/bin/hd-idle -i 600";
      };
    };
  };
}

