{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;

    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
    shortcut = "b";
    baseIndex = 1;
    keyMode = "vi";
    sensibleOnTop = true;
    aggressiveResize = true;

    plugins = with pkgs.tmuxPlugins; [
      yank
      open
      sensible
    ];

    extraConfig = ''
      unbind C-BSpace
      unbind C-Left
      unbind C-Right

      # enable vermin
      set -g mouse on
      set -g extended-keys on

      # loud or quiet?
      set -g visual-activity on
      set -g visual-bell off
      set -g visual-silence off
      setw -g monitor-activity off
      set -g bell-action none

      # No status bar at all -- it always reserves its own row even with an
      # empty/transparent format. The shell prompt shows a [tmux] indicator
      # instead (see confs/shell.nix), which costs no extra rows.
      set -g status off
      set -g set-titles-string "tmux: #I #W"

      # Bindings
      # more intuitive keybindings for splitting
      unbind %
      bind % split-window -h -c "#{pane_current_path}"
      unbind '"'
      bind - split-window -v -c "#{pane_current_path}"

      # break pane into a new window
      bind ^ break-pane -d

      # Golden-ratio dev layout: left pane (~62%) gets nvim with a netrw
      # sidebar, right pane (~38%) is a plain shell for vim-slime's REPL target
      bind G split-window -h -p 38 -c "#{pane_current_path}" \; split-window -v -p 38 -c "#{pane_current_path}" \; select-pane -L \; send-keys "nvim -c Lexplore" Enter
    '';
  };
}
