{ config, pkgs, ... }:

let
  packs = import ./packages/default.nix pkgs;
  nnn_fzcd = import ./scripts/nnn_fzcd.nix pkgs;
  nnn_helper = import ./scripts/nnn_helper.nix pkgs;
in {
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
      "vis/visrc.lua".source = ./confs/visrc.lua;
      "vis/vis-repl.lua".source = ./confs/vis-repl.lua;
      "euporie/config.json".source = ./confs/euporie.json;
      # NNN plugins
      "nnn/plugins/fzcd".source = "${nnn_fzcd}/bin/fzcd";
      "nnn/plugins/.nnn-plugin-helper".source = "${nnn_helper}/bin/nnn_helper";
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

    # define some user based variables
    sessionVariables = {
      VISUAL = "${pkgs.vis}/bin/vis";
      EDITOR = "${pkgs.vis}/bin/vis";
      TERMINAL = "${pkgs.foot}/bin/foot";
    };

    # You should not change this value, even if you update Home Manager.
    stateVersion = "25.11";
  };
  # Notifications about home-manager news
  news.display = "silent";
}
