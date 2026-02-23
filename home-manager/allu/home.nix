{ config, pkgs, ... }:

{
  # Import and source other configuration files
  imports = [
    ./confs/shell.nix
    ./confs/tmux.nix
    ./confs/plasma.nix
    ./packages/default.nix
  ];

  targets.genericLinux.enable = true;
  nixpkgs.config.allowUnfree = true;
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  xdg = {
    enable = true;
    mime.enable = true;
    configFile = {
      "foot/foot.ini".source = ./confs/foot.ini;
      "nvim/init.lua".source = ./confs/nvim.lua;
      "euporie/config.json".source = ./confs/euporie.json;
      "lf/lfrc".source = ./confs/lfrc;
    };
  };

  # Other configuration settings
  fonts.fontconfig.enable = true;
    dconf = {
      enable = true;
      settings = {
        "org/virt-manager/virt-manager/connections" = {
        autoconnect = ["qemu:///system"];
        uris = ["qemu:///system"];
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

    # You should not change this value, even if you update Home Manager.
    stateVersion = "26.05";
  };
  # Notifications about home-manager news
  news.display = "silent";
}
