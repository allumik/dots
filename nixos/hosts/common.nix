# hosts/common.nix
# Common settings with all the bells and tools for all hosts
# addition to hosts/base.nix
{ config, pkgs, ... }:

{
  ## Nixpkgs coniguration for all hosts
  nixpkgs.config.allowUnfree = true;

  ## Core packages and services
  environment.systemPackages = with pkgs; [
    # Utilities
    coreutils-full dnsutils pciutils v4l-utils findutils libtool ethtool fwupd hd-idle ntfsprogs-plus cachix libsixel
    jq pixi uv dos2unix parted usbutils
    # Development & Build
    gnumake cmake gcc cargo rustc tlp auto-cpufreq
    # Default terminal
    foot
    # CLI Tools
    lnav parallel retry pigz unrar plocate nix-search-cli gitFull gh miller
    # Monitoring
    s-tui stress htop
    # Media & Files
    vlc ffmpeg fdupes bluez-experimental pulseaudioFull exfatprogs
    # Other GUI
    transmission_4-qt keepassxc gimp3-with-plugins
    eduvpn-client openvpn libreoffice-qt zotero thunderbird 
    vscode.fhs
  ];
  fonts.packages = with pkgs; [
    # Font packs for compatibility
    unifont corefonts vista-fonts noto-fonts liberation_ttf 
    # Pretty symbol packs, often used as fallback symbols
    font-awesome material-icons powerline-symbols
    # Some fonts
    aporetic ibm-plex vt323 fixedsys-excelsior
    hack-font source-code-pro nerd-fonts.iosevka-term
    merriweather merriweather-sans
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
    };
  };

  programs = {
    nix-ld.enable = true; # might make your life easier with linked library adapter
  };
 

  ## Extras
  systemd.services = {
    # Spin down HDDs after 5 minutes
    hd-idle = {
      description = "External HD spin down daemon";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.hd-idle}/bin/hd-idle -i 300";
      };
    };
  };
}

