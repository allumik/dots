{ config, pkgs, ... }:

let
  packs = import ./packages/default.nix pkgs;
  nnn_fzcd = import ./scripts/nnn_fzcd.nix pkgs;
  nnn_helper = import ./scripts/nnn_helper.nix pkgs;
in {
  # Import other configuration files
  imports = [
    ./confs/shell.nix
    ./confs/tmux.nix
    ./confs/plasma.nix
  ];
  xdg = {
    enable = true;
    mime.enable = true;
    configFile = {
      "foot/foot.ini".source = ./confs/foot.ini;
      "vis/visrc.lua".source = ./confs/visrc.lua;
      "euporie/config.json".source = ./confs/euporie.json;
      # NNN plugins
      "nnn/plugins/fzcd".source = "${nnn_fzcd}/bin/fzcd";
      "nnn/plugins/.nnn-plugin-helper".source = "${nnn_helper}/bin/nnn_helper";
    };
  };


  # Programs & Services
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };
  nixpkgs.config.allowUnfree = true;
  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
    brave = {
      enable = true;
      commandLineArgs = [ "--ozone-platform=wayland" ];
      nativeMessagingHosts = [ pkgs.kdePackages.plasma-browser-integration ];
    };
    vscode.enable = true;
  };
  services = {
    syncthing = {
      enable = true;
      tray.enable = true;
    };
  };
  targets.genericLinux.enable = true;


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

    # Userspace applications
    packages = packs.programs ++ packs.fonts;

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
