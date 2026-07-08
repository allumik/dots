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
      prefix-highlight
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

      # Statusbar layout (colors come from Stylix's base16 tmux target, sourced above)
      # use i for current info
      # set -g status off
      set -g status-position top
      set -g set-titles-string "tmux: #I #W"
      set -g status-justify centre
      set -g status-left ' #H '
      set -g status-right '#{prefix_highlight} %m/%d/%y ~ %H:%M '

      setw -g window-status-format ' #I ~ #W '
      setw -g window-status-current-style 'bold'
      setw -g window-status-current-format '[#I ~ #W]'

      # Bindings
      # more intuitive keybindings for splitting
      unbind %
      bind % split-window -h -c "#{pane_current_path}"
      unbind '"'
      bind - split-window -v -c "#{pane_current_path}"

      # break pane into a new window
      bind ^ break-pane -d
    '';
  };
}
