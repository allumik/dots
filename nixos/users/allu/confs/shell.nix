{ config, lib, pkgs, ... }:

let
  sessvars = {
    # put dotfiles first!
    LC_COLLATE = "C";
  };

  ## for both zsh and bash
  aliases = {
    cp      = "cp -i";     # confirm before overwriting something
    df      = "df -h";     # human-readable sizes
    free    = "free -m"; # show sizes in MB
    np      = "nano -w PKGBUILD";
    more    = "less";
    ls      = "ls --color=auto";
    la      = "ls -A";
    ll      = "${pkgs.eza}/bin/eza -alF";

    zl     = "${pkgs.zellij}/bin/zellij";
    of      = "xdg-open '$(fzf --preview '${pkgs.bat} {}')'";
    es      = "$EDITOR '$(fzf --preview '${pkgs.bat} {}')'";

    cdwin   = "cd /mnt/c/Users/alvin";
    wv      = "wslview";
  };

  xdgDataDirs = "export XDG_DATA_DIRS=$HOME/.nix-profile/share:$HOME/.nix-profile/share/applications:$XDG_DATA_DIRS";
in
{
  programs = {

    bash = {
      enable = true;

      profileExtra = xdgDataDirs;
      bashrcExtra = ''
        # set a fancy prompt (non-color, unless we know we "want" color)
        case "$TERM" in
            xterm-color|*-256color) color_prompt=yes;;
        esac

        if [ "$color_prompt" = yes ]; then
            PS1=' ''${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
        else
            PS1=' ''${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
        fi
        unset color_prompt force_color_prompt

        # If this is an xterm set the title to user@host:dir
        case "$TERM" in
        xterm*|rxvt*)
            PS1="\[\e]0;''${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
            ;;
        *)
            ;;
        esac

        # enable color support of ls and also add handy aliases
        if [ -x /usr/bin/dircolors ]; then
            test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
        fi
      '';
      sessionVariables = sessvars;
      shellAliases = aliases;
    };

    zsh = {
      enable = true;
      enableCompletion = true;

      autosuggestion.enable = true;
      history.extended = true;

      profileExtra = xdgDataDirs;
      sessionVariables = sessvars;
      shellAliases = aliases;

      plugins = [
        {
          name = "fast-syntax-highlighting";
          file = "fast-syntax-highlighting.plugin.zsh";
          src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions";
        }
        {
          name = "zsh-nix-shell";
          file = "nix-shell.plugin.zsh";
          src = "${pkgs.zsh-nix-shell}/share/zsh-nix-shell";
        }
        {
          name = "zsh-fzf-tab";
          file = "fzf-tab.plugin.zsh";
          src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
        }
      ];

      oh-my-zsh = {
        enable = true;
        theme = "nicoulaj";
        plugins = [
          "fzf"
          "extract"
	  "gitfast"
	  "gh"
	  "rsync"
	  "rclone"
	  "python"
	  "uv"
        ];
      };
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;

      defaultOptions = [ "--height 40%" ];
      fileWidgetOptions = [ "--preview 'bat {}'" ];
      changeDirWidgetOptions = [ "--preview 'bat {}'" ];
    };

    bat = {
      enable = true;
      # This should pick up the correct colors for the generated theme. Otherwise
      # it is possible to generate a custom bat theme to ~/.config/bat/config
      config = {
        theme = "base16";
        color = "always";
        style = "numbers";
        line-range = ":500";
      };
    };
  };
}
