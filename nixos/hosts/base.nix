# hosts/base.nix
# Common settings for all hosts
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

  environment.systemPackages = with pkgs; [
    # Core Tools
    vis fzf nnn ripgrep wget zip unzip p7zip
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
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
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
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
  system.stateVersion = "25.05";
}
