# hosts/base.nix
# Shared settings for all hosts: locale/timezone/nix settings, core CLI
# tools, and the "full desktop" layer (fonts, portals, bluetooth, pipewire).
# Host-specific config (networking, niri, packages, users) lives in
# hosts/<host>.nix; theming lives in hosts/stylix.nix.
{ config, pkgs, ... }:

let
  extraLocale = "nl_NL.UTF-8";
in
{
  # Enable Flakes and nix-command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Set timezone and locale
  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = extraLocale;
    LC_IDENTIFICATION = extraLocale;
    LC_MEASUREMENT = extraLocale;
    LC_MONETARY = extraLocale;
    LC_NAME = extraLocale;
    LC_NUMERIC = extraLocale;
    LC_PAPER = extraLocale;
    LC_TELEPHONE = extraLocale;
    LC_TIME = extraLocale;
  };

  nixpkgs.config.allowUnfree = true;

  environment = {
    systemPackages = with pkgs; [
      # Core Tools
      neovim tre fzf fd lf ripgrep wget lz4 zip unzip p7zip difftastic moreutils
      # Utilities
      coreutils-full dnsutils pciutils v4l-utils findutils libtool ethtool fwupd hd-idle ntfsprogs-plus cachix libsixel
      jq pixi uv dos2unix parted usbutils
      # Development & Build
      gnumake cmake gcc cargo rustc tlp auto-cpufreq
      # Default terminal
      foot
      # CLI Tools
      xan parallel retry pigz unrar plocate nix-search-cli gitFull gh miller
      # Monitoring
      s-tui stress htop
      # Media & Files
      vlc ffmpeg fdupes bluez-experimental pulseaudioFull exfatprogs
      # Other GUI
      transmission_4-qt keepassxc gimp3-with-plugins
      eduvpn-client openvpn libreoffice-qt zotero thunderbird
      vscode.fhs
    ];
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "less";
    };
    pathsToLink = [
      "/share/applications"
      "/share/xdg-desktop-portal"
    ];
  };

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

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    # gtk handles file pickers (lighter, themeable); gnome is kept only for
    # ScreenCast/RemoteDesktop, since niri implements the GNOME Shell DBus
    # interface those portals expect.
    config.common = {
      default = [ "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
      "org.freedesktop.impl.portal.RemoteDesktop" = [ "gnome" ];
    };
  };

  ## Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    nix-ld.enable = true; # might make your life easier with linked library adapter
    xfconf.enable = true; # backs home-manager's xfconf.settings (Thunar view prefs)
  };

  services = {
    # X server and desktop environment
    xserver = {
      enable = true;
      xkb.layout = "ee";
      xkb.variant = "us";
    };
    # SSH Daemon
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        X11Forwarding = true;
      };
    };
    # fstrim/flatpak are opt-in per host (see hosts/<host>.nix)
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    udisks2.enable = true; # mount backend thunar-volman automounts through
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

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };

  # Automatic system upgrades
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true; # reboot when new kernel

  # Set the state version
  system.stateVersion = "26.05";
}
