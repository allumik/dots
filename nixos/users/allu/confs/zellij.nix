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
    tab_template name="ui" {
      pane size=1 borderless=true {
        plugin location="zellij:compact-bar"
      }
      children
    }

    ui

    swap_tiled_layout name="vertical" {
      ui max_panes=4 {
        pane split_direction="vertical" {
          children
        }
      }
      ui max_panes=7 {
        pane split_direction="vertical" {
          pane { children; }
          pane { pane; pane; pane; pane; }
        }
      }
      ui max_panes=11 {
        pane split_direction="vertical" {
          pane { children; }
          pane { pane; pane; pane; pane; }
          pane { pane; pane; pane; pane; }
        }
      }
    }

    swap_tiled_layout name="horizontal" {
      ui max_panes=3 {
        pane
        pane
      }
      ui max_panes=7 {
        pane {
          pane split_direction="vertical" { children; }
          pane split_direction="vertical" { pane; pane; pane; pane; }
        }
      }
      ui max_panes=11 {
        pane {
          pane split_direction="vertical" { children; }
          pane split_direction="vertical" { pane; pane; pane; pane; }
          pane split_direction="vertical" { pane; pane; pane; pane; }
        }
      }
    }

    swap_tiled_layout name="stacked" {
      ui min_panes=4 {
        pane split_direction="vertical" {
          pane
          pane stacked=true { children; }
        }
      }
    }

    swap_floating_layout name="staggered" {
      floating_panes
    }

    swap_floating_layout name="enlarged" {
      floating_panes max_panes=10 {
        pane { x "5%"; y 1; width "90%"; height "90%"; }
        pane { x "5%"; y 2; width "90%"; height "90%"; }
        pane { x "5%"; y 3; width "90%"; height "90%"; }
        pane { x "5%"; y 4; width "90%"; height "90%"; }
        pane { x "5%"; y 5; width "90%"; height "90%"; }
        pane { x "5%"; y 6; width "90%"; height "90%"; }
        pane { x "5%"; y 7; width "90%"; height "90%"; }
        pane { x "5%"; y 8; width "90%"; height "90%"; }
        pane { x "5%"; y 9; width "90%"; height "90%"; }
        pane { x 10; y 10; width "90%"; height "90%"; }
      }
    }
  }
  '';
}
