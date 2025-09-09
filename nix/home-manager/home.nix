{ config, pkgs, ... }:

let
  packs = import ./packages.nix pkgs;
  nnn_fzcd = import ./scripts/nnn_fzcd.nix pkgs;
  nnn_helper = import ./scripts/nnn_helper.nix pkgs;

  nixvim = import (builtins.fetchGit {
    url = "https://github.com/nix-community/nixvim";
    ref = "main";
  });
in {
  home = {
    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    username = "allu";
    homeDirectory = "/home/allu";

    # Userspace applications
    packages = packs.programs ++ packs.fonts;

    # * The PATH for me *
    sessionPath = [ 
      "$HOME/.config/home-manager/scripts"
      "$HOME/.nix-profile/bin"
    ];

    # define some user based variables
    sessionVariables = {
      VISUAL = "nvim"; # "code" in graphical user
      EDITOR = "nvim";
      TERMINAL = "alacritty";
      # XDG_DATA_DIRS = "$HOME/.nix-profile/share/applications:$XDG_DATA_DIRS";
			NIXOS_OZONE_WL = "1";
    };

    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "25.05";
  };

  # Load in bigger configuration submodules
  imports = [
    nixvim.homeModules.nixvim
    ./confs/shell.nix
    ./confs/tmux.nix
    # ./kak.nix # don't use kak anymore
    ./confs/nvim.nix

    # vs-code magic sauce
    "${fetchTarball "https://github.com/msteen/nixos-vscode-server/tarball/master"}/modules/vscode-server/home.nix"
  ];

  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nix;
    # enable flakes
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  fonts.fontconfig.enable = true;

  # describe other less important settings not defined in imports
  # or in packages...
  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
    ssh.enable = true;
    vscode.enable = true;

    brave = {
      enable = true;
      commandLineArgs = [
        "--enable-features=VaapiVideoDecodeLinuxGL"
        "--use-gl=angle"
        "--use-angle=gl"
        "--ozone-platform=wayland"
      ];
    };
  };

  services = {
    vscode-server.enable = true;

    syncthing = {
      enable = true;
      tray.enable = true;
    };
  };
  targets.genericLinux.enable = true;

  xdg = {
    enable = true;
    mime.enable = true;

    configFile = {
      ## NNN plugins
      "nnn/plugins/fzcd".source = "${nnn_fzcd}/bin/fzcd";
      "nnn/plugins/.nnn-plugin-helper".source = "${nnn_helper}/bin/nnn_helper";
    };
  };

	dconf = {
    enable = true;
    settings = {
  	  "org/virt-manager/virt-manager/connections" = {
      	autoconnect = ["qemu:///system"];
      	uris = ["qemu:///system"];
  	  };
    };
	};

  # notifications about home-manager news
  news.display = "silent";
}
