{ config, pkgs, ... }:

{
  programs.zellij = {
    enable = true;

    settings = {
      default_shell = "${pkgs.zsh}/bin/zsh";
      default_layout = "top_compact";
      theme = "ansi";
      pane_frames = false;
      show_startup_tips = false;
      hide_session_name = true;
      simplified_ui = true;
    };
  };

  # Define the default layout to position the bar at the top with custom layout
  xdg.configFile."zellij/layouts/top_compact.kdl".text = ''
    layout {
      pane size=1 borderless=true {
        plugin location="zellij:compact-bar"
      }
      pane
    }
  '';
}
