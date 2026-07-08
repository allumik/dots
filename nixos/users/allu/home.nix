{ config, pkgs, ... }:

{
  targets.genericLinux.enable = true;

  # Import and source other configuration files
  imports = [
    ./confs/shell.nix
    ./confs/tmux.nix
    ./confs/desktop.nix
  ];

  xdg = {
    enable = true;
    mime.enable = true;
    configFile = {
      "nvim/init.lua".source = ./confs/init.lua;
      "lf/lfrc".source = ./confs/lfrc;
      "euporie/config.json".source = ./confs/euporie.json;
      "niri/config.kdl".source = ./confs/niri.kdl;
      "waycorner/config.toml".source = ./confs/waycorner.toml;
    };
  };

  # Claude Code personal skill so agents know how to drive herdr (HERDR_ENV=1)
  home.file.".claude/skills/herdr/SKILL.md".source = ./confs/herdr-skill.md;

  # Claude Code global settings (TUI/statusline prefs, ponytail plugin, herdr hook).
  # Nix-managed means read-only: /config and other in-app writes to this file
  # will fail. Edit ./confs/claude-settings.json and rebuild instead.
  home.file.".claude/settings.json".source = ./confs/claude-settings.json;

  # herdr: sandbox new panes' default shell via bubblewrap
  home.file.".config/herdr/config.toml".source = ./confs/herdr-config.toml;
  home.file.".local/bin/herdr-sandboxed-shell" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Default shell herdr launches new panes with, sandboxed via nix-bwrap.
      # Exposes: cwd, the Nix store closure of the shell (via nix-bwrap),
      # network (for claude-code/API access), and a handful of config dirs
      # agents need (Claude Code state, git identity, herdr's own config,
      # local data dir). Everything else on the host is hidden.
      set -euo pipefail

      cwd="$PWD"
      binds=(--bind "$cwd" "$cwd")

      for path in "$HOME/.claude" "$HOME/.config/git" "$HOME/.gitconfig" "$HOME/.config/herdr" "$HOME/.local/share"; do
        [ -e "$path" ] && binds+=(--bind "$path" "$path")
      done

      exec nix-bwrap -net -bwrap-options "''${binds[*]}" -- "${pkgs.zsh}/bin/zsh" -l
    '';
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
    # for the cursor theme
    hackneyed
  ];

    # You should not change this value, even if you update Home Manager.
    stateVersion = "26.05";
  };
  # Notifications about home-manager news
  news.display = "silent";
}
 
