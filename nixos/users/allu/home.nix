{ config, pkgs, ... }:

{
  targets.genericLinux.enable = true;

  # Import and source other configuration files
  imports = [
    ./confs/shell.nix
    ./confs/zellij.nix
  ];

  xdg = {
    enable = true;
    mime.enable = true;
    configFile = {
      "nvim/init.lua".source = ./confs/nvim.lua;
      "lf/lfrc".source = ./confs/lfrc;
      "euporie/config.json".source = ./confs/euporie.json;
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
 
