# hosts/base.nix
# Shared by every host, graphical or not: nix settings, locale/timezone,
# core CLI tools, ssh, gc. Nothing here assumes a screen, speakers, or real
# hardware - that layer is hosts/desktop.nix; theming is hosts/stylix.nix.
# Host-specific config (networking, niri, packages, users) lives in
# hosts/<host>.nix.
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
      coreutils-full dnsutils pciutils v4l-utils findutils libtool ethtool fwupd ntfsprogs-plus cachix libsixel
      jq pixi uv dos2unix parted usbutils
      # Development & Build
      gnumake cmake gcc cargo rustc
      nodejs-slim # runtime-only Node (no npm/corepack) for nvim tooling; use `nodejs` if a tool needs npm
      # CLI Tools
      xan parallel retry pigz unrar plocate nix-search-cli gitFull gh miller
      # Monitoring
      s-tui stress htop
    ];
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "less";
    };
  };

  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    nix-ld.enable = true; # might make your life easier with linked library adapter
  };

  services = {
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
  };

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };

  # Hardlink identical files across store paths. Worth a lot here: several
  # nixpkgs revisions are retained at once and they share most of their files.
  nix.optimise.automatic = true;

  # Set the state version
  system.stateVersion = "26.05";
}
