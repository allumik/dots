{ config, pkgs, ... }:

{
  targets.genericLinux.enable = true;

  # Import and source other configuration files
  imports = [
    ./confs/shell.nix
    ./confs/zellij.nix
    ./confs/desktop.nix
  ];

  xdg = {
    enable = true;
    mime.enable = true;
    configFile = {
      "nvim/init.lua".source = ./confs/nvim.lua;
      "lf/lfrc".source = ./confs/lfrc;
      "euporie/config.json".source = ./confs/euporie.json;
      "niri/config.kdl".source = ./confs/niri.kdl;
      "waycorner/config.toml".source = ./confs/waycorner.toml;
    };
    portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-termfilechooser ];
      config = {
        common = {
          default = [ "gtk" ];
          "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
        };
      };
    };
  };


  # General home-manager settings
  home = {
    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    username = "allu";
    homeDirectory = "/home/allu";

    # * The PATH for me *
    sessionPath = [ 
      "$HOME/.nix-profile/bin"
      "$HOME/.local/bin" 
    ];

    file.".config/xdg-desktop-portal-termfilechooser/config".text = ''
      [filechooser]
      cmd=${config.home.homeDirectory}/.config/xdg-desktop-portal-termfilechooser/wrapper.sh %s
    '';

    file.".config/xdg-desktop-portal-termfilechooser/wrapper.sh" = {
      executable = true;
      text = ''
        #!/bin/sh
        set -e
        out="$1"
        foot -a termfilechooser -e lf -selection-path "$out"
      '';
    };

    packages = with pkgs; [
      ## Tools & Shells
      # some minuscle stuff for python/R environments
      libssh libxml2 libpng libxslt libtiff cairo  # R needs this
      # terminal bling
      zsh zsh-nix-shell zsh-fast-syntax-highlighting zsh-fzf-tab
    ];

    # You should not change this value, even if you update Home Manager.
    stateVersion = "26.05";
  };
  # Notifications about home-manager news
  news.display = "silent";
}
 
