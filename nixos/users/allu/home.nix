{ config, pkgs, ... }:

{
  targets.genericLinux.enable = true;

  # Import and source other configuration files. desktop.nix is NOT imported
  # here: the graphical hosts add it themselves (see hosts/deskmeat.nix and
  # hosts/oldlenno.nix) so headless hosts like wsl-nix can take this file
  # without dragging in waybar/fuzzel/brave.
  imports = [
    ./shell.nix
    ./tmux.nix
  ];

  xdg = {
    enable = true;
    mime.enable = true;
    configFile = {
      "nvim/init.lua".source = ./confs/init.lua;
      "lf/lfrc".source = ./confs/lfrc;
      "matplotlib/matplotlibrc".text = ''
        # Plots served over HTTP instead of a GUI window, so they're viewable
        # from any browser on the tailnet (tailscale0 is already firewall-trusted).
        backend: webagg
        webagg.address: 0.0.0.0
        webagg.open_in_browser: False
      '';
    };
  };

  # Claude Code global settings (TUI/statusline prefs, ponytail plugin).
  # Nix-managed means read-only: /config and other in-app writes to this file
  # will fail. Edit ./confs/claude-settings.json and rebuild instead.
  home.file.".claude/settings.json".source = ./confs/claude-settings.json;

  # SSH client config is hand-rolled at ~/.ssh/config (NOT managed here), so
  # internal hostnames/usernames/topology stay out of this public repo.
  # It holds the `abacus` alias: plikgr0003 reached by ProxyJump through the
  # gl-ar300m router (a tailnet peer), identityFile ~/.ssh/deskmeat.

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
 
