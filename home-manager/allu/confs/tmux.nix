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

    plugins = with pkgs; [
      tmuxPlugins.yank
      tmuxPlugins.open
      tmuxPlugins.resurrect
      tmuxPlugins.sensible
      tmuxPlugins.continuum
      tmuxPlugins.prefix-highlight
      tmuxPlugins.vim-tmux-navigator
    ];

    extraConfig = ''
      unbind C-BSpace
      unbind C-Left
      unbind C-Right

      # loud or quiet?
      set -g visual-activity on
      set -g visual-bell off
      set -g visual-silence off
      setw -g monitor-activity off
      set -g bell-action none

      # Statusbar
      # use i for current info
      # set -g status off
      set -g status-position top
      set -g status-style 'fg=#EEEEEE bg=default'
      set -g set-titles-string "tmux: #I #W"
      set -g status-justify centre
      set -g status-left ' #[fg=green]#H #[default]'
      set -g status-right '#{prefix_highlight} #[fg=green] %m/%d/%y ~ %H:%M '

      setw -g window-status-format ' #I ~ #W '
      setw -g window-status-current-style 'bold'
      setw -g window-status-current-format '[#I ~ #W]'
      setw -g window-status-bell-style 'fg=red'

      # Borders 
      set -g pane-active-border-style fg=#151515
      set -g pane-active-border-style bg=default
      set -g pane-border-style fg=#151515
      set -g pane-border-style bg=default

      # Bindings
      # more intuitive keybindings for splitting
      unbind %
      bind % split-window -h -c "#{pane_current_path}"
      unbind '"'
      bind - split-window -v -c "#{pane_current_path}" 

      # break pane into a new window
      bind ^ break-pane -d

      # enable continuum automatic restore
      set -g @continuum-restore 'on'
    '';
  };
}
