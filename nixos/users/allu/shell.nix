{ config, lib, pkgs, ... }:

let
  sessvars = {
    # put dotfiles first!
    LC_COLLATE = "C";
  };

  ## for both zsh and bash
  aliases = {
    cp      = "cp -i";
    # confirm before overwriting something
    df      = "df -h";
    # human-readable sizes
    free    = "free -m";
    # show sizes in MB
    np      = "nano -w PKGBUILD";
    more    = "less";
    ls      = "ls --color=auto";
    la      = "ls -A";
    ll      = "${pkgs.eza}/bin/eza -alF";

    tux     = "${pkgs.tmux}/bin/tmux new-session -A -s main";
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

        if [ "$color_prompt" = yes ];
        then
            PS1=' ''${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
        else
            PS1=' ''${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
        fi
        unset color_prompt force_color_prompt
        # tmux position: window/windows|session/sessions, e.g. 1/3|1/2
        # (see the zsh helper below for how)
        _tmux_pos() {
          local w=$(tmux list-windows -F "#{window_active}" 2>/dev/null \
            | awk '$0==1{i=NR} END{print i"/"NR}')
          local s=$(tmux list-sessions -F "#{session_id}" 2>/dev/null \
            | awk -v c="''${TMUX##*,}" 'substr($0,2)==c{i=NR} END{print i"/"NR}')
          printf '%s|%s' "$w" "$s"
        }
        [ -n "$TMUX" ] && PS1="[tmux \$(_tmux_pos)]$PS1"

        # If this is an xterm set the title to user@host:dir
        case "$TERM" in
        xterm*|rxvt*)

            PS1="\[\e]0;''${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
            ;;
        *)
            ;;
        esac

        # enable color support of ls and also add handy aliases
        if [ -x /usr/bin/dircolors ];
        then
            test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" ||
            eval "$(dircolors -b)"
        fi

        update-nixos() {
          local target_dir=''${1:-~/Projects/dots/nixos}
          nix flake update --flake "$target_dir" && sudo nixos-rebuild switch --flake "$target_dir"
        }

        # claude, sandboxed via nix-bwrap: same trust boundary as
        # herdr-sandboxed-shell (cwd, .claude, git identity, network), just
        # run directly from any terminal instead of only inside herdr panes.
        claudy() {
          local binds=(--bind "$PWD" "$PWD") p
          for p in "$HOME/.claude" "$HOME/.config/git" "$HOME/.gitconfig" "$HOME/.local/share"; do
            [ -e "$p" ] && binds+=(--bind "$p" "$p")
          done
          nix-bwrap -net -bwrap-options "''${binds[*]}" -- claude "$@"
        }
      '';
      sessionVariables = sessvars;
      shellAliases = aliases;
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      history.extended = true;

      envExtra = ''
        ${xdgDataDirs}

        update-nixos() {
          local target_dir=''${1:-~/Projects/dots/nixos}
          nix flake update --flake "$target_dir" && sudo nixos-rebuild switch --flake "$target_dir"
        }

        # claude, sandboxed via nix-bwrap: same trust boundary as
        # herdr-sandboxed-shell (cwd, .claude, git identity, network), just
        # run directly from any terminal instead of only inside herdr panes.
        # NB: loop var is `p`, not `path` -- in zsh `path` is tied to $PATH,
        # so looping over it would wipe PATH and lose nix-bwrap.
        claudy() {
          local binds=(--bind "$PWD" "$PWD") p
          for p in "$HOME/.claude" "$HOME/.config/git" "$HOME/.gitconfig" "$HOME/.local/share"; do
            [ -e "$p" ] && binds+=(--bind "$p" "$p")
          done
          nix-bwrap -net -bwrap-options "''${binds[*]}" -- claude "$@"
        }
      '';
      # runs after oh-my-zsh sets $PROMPT, so this prefix survives the theme
      initContent = ''
        # tmux position: window/windows|session/sessions, e.g. 1/3|1/2.
        # window: active window's ordinal among this session's windows.
        # session: $TMUX's third comma-field is our session-id number;
        # list-sessions is name-sorted so NR is a stable ordinal.
        _tmux_pos() {
          local w=$(tmux list-windows -F "#{window_active}" 2>/dev/null \
            | awk '$0==1{i=NR} END{print i"/"NR}')
          local s=$(tmux list-sessions -F "#{session_id}" 2>/dev/null \
            | awk -v c="''${TMUX##*,}" 'substr($0,2)==c{i=NR} END{print i"/"NR}')
          printf '%s|%s' "$w" "$s"
        }
        setopt prompt_subst  # so the $(...) below re-runs each render
        [[ -n "$TMUX" ]] && PROMPT="%F{cyan}[tmux \$(_tmux_pos)]%f $PROMPT"
      '';
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
          "tmux"
        ];
      };
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultOptions = [ "--height 40%" ];
      fileWidget.options = [ "--preview 'bat {}'" ];
      changeDirWidget.options = [ "--preview 'bat {}'" ];
    };

    bat = {
      enable = true;
      # theme is set by Stylix (base16-stylix) to match the rest of the desktop
      config = {
        color = "always";
        style = "numbers";
        line-range = ":500";
      };
    };
  };
}
