# hosts/desktop.nix
# The "full desktop" layer: everything that assumes a screen, sound,
# bluetooth, and real spinning hardware. Imported by the graphical hosts
# (deskmeat, oldlenno) alongside base.nix; headless hosts (wsl-nix) import
# base.nix only. Theming for this layer is hosts/stylix.nix, kept separate
# since it is toggled/tweaked independently.
{ config, pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [
      # Power management / spinning disks
      tlp auto-cpufreq hd-idle
      # Default terminal
      foot
      # Media & Files
      vlc ffmpeg fdupes bluez-experimental pulseaudioFull exfatprogs
      # Other GUI
      transmission_4-qt keepassxc gimp3-with-plugins
      eduvpn-client openvpn libreoffice-qt zotero thunderbird
      vscode.fhs
    ];
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
    hack-font source-code-pro
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

  services = {
    blueman.enable = true;
    # X server and desktop environment
    xserver = {
      enable = true;
      xkb.layout = "ee";
      xkb.variant = "us";
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    udisks2.enable = true; # removable-media mount backend Dolphin drives via solid
    # gvfs: kept for the libmtp udev rules it installs (phones over USB, which
    # Dolphin reaches as mtp:/ through kio-extras) and for trash/network in
    # GTK apps' file dialogs. Also flips programs.fuse on.
    gvfs.enable = true;
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
