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

        # claude, sandboxed via nix-bwrap: exposes cwd, Claude Code state,
        # git identity, host tools and network. Rest of $HOME stays hidden.
        claudy() {
          # --proc/--dev: nix-bwrap mounts neither; claude's bun runtime needs
          # /proc/self/exe to self-extract and /dev/null for stdio, else SIGABRT.
          # store+etc+current-system: nix-bwrap binds only claude's own closure,
          # so without these the sandbox has no host tools (git, rg, coreutils)
          # and every ~/.config symlink into the store dangles.
          # /bin + /usr/bin: both hold nothing but symlinks into the store, and
          # without them hooks die on posix_spawn '/bin/sh' and every
          # `#!/usr/bin/env` shebang fails.
          # --setenv PATH: nix-bwrap forces PATH=/no-such-path (it binds only
          # the command's own closure), so anything claude shells out to - node
          # in plugin hooks, git, rg - is not found without this.
          local binds=(
            --proc /proc --dev /dev --tmpfs /tmp
            --ro-bind /nix/store /nix/store
            --ro-bind /etc /etc
            --ro-bind /run/current-system /run/current-system
            --ro-bind /bin /bin --ro-bind /usr/bin /usr/bin
            --setenv PATH "/run/current-system/sw/bin:$HOME/.local/bin"
            --bind "$PWD" "$PWD"
          ) p
          # Same problem as PATH. nix-bwrap forces TERM=dumb, which is what
          # kills claude's full-screen rendering, and blanks the locale vars,
          # which mangles its box-drawing characters. LOCALE_ARCHIVE is how
          # glibc finds locale data at all on NixOS.
          [ -n "$TERM" ] && binds+=(--setenv TERM "$TERM")
          [ -n "$COLORTERM" ] && binds+=(--setenv COLORTERM "$COLORTERM")
          [ -n "$TERMINFO_DIRS" ] && binds+=(--setenv TERMINFO_DIRS "$TERMINFO_DIRS")
          [ -n "$LANG" ] && binds+=(--setenv LANG "$LANG")
          [ -n "$LOCALE_ARCHIVE" ] && binds+=(--setenv LOCALE_ARCHIVE "$LOCALE_ARCHIVE")
          # ~/.config is NOT bound wholesale: it holds browser profiles and
          # other secrets. List the dirs the agent actually needs.
          for p in "$HOME/.claude" "$HOME/.claude.json" "$HOME/.gitconfig" "$HOME/.local/share" \
                   "$HOME/.config/git" "$HOME/.config/zsh" "$HOME/.config/nvim" \
                   "$HOME/.config/tmux" "$HOME/.config/lf"; do
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

        # claude, sandboxed via nix-bwrap: exposes cwd, Claude Code state,
        # git identity, host tools and network. Rest of $HOME stays hidden.
        # NB: loop var is `p`, not `path` -- in zsh `path` is tied to $PATH,
        # so looping over it would wipe PATH and lose nix-bwrap.
        claudy() {
          # --proc/--dev: nix-bwrap mounts neither; claude's bun runtime needs
          # /proc/self/exe to self-extract and /dev/null for stdio, else SIGABRT.
          # store+etc+current-system: nix-bwrap binds only claude's own closure,
          # so without these the sandbox has no host tools (git, rg, coreutils)
          # and every ~/.config symlink into the store dangles.
          # /bin + /usr/bin: both hold nothing but symlinks into the store, and
          # without them hooks die on posix_spawn '/bin/sh' and every
          # `#!/usr/bin/env` shebang fails.
          # --setenv PATH: nix-bwrap forces PATH=/no-such-path (it binds only
          # the command's own closure), so anything claude shells out to - node
          # in plugin hooks, git, rg - is not found without this.
          local binds=(
            --proc /proc --dev /dev --tmpfs /tmp
            --ro-bind /nix/store /nix/store
            --ro-bind /etc /etc
            --ro-bind /run/current-system /run/current-system
            --ro-bind /bin /bin --ro-bind /usr/bin /usr/bin
            --setenv PATH "/run/current-system/sw/bin:$HOME/.local/bin"
            --bind "$PWD" "$PWD"
          ) p
          # Same problem as PATH. nix-bwrap forces TERM=dumb, which is what
          # kills claude's full-screen rendering, and blanks the locale vars,
          # which mangles its box-drawing characters. LOCALE_ARCHIVE is how
          # glibc finds locale data at all on NixOS.
          [ -n "$TERM" ] && binds+=(--setenv TERM "$TERM")
          [ -n "$COLORTERM" ] && binds+=(--setenv COLORTERM "$COLORTERM")
          [ -n "$TERMINFO_DIRS" ] && binds+=(--setenv TERMINFO_DIRS "$TERMINFO_DIRS")
          [ -n "$LANG" ] && binds+=(--setenv LANG "$LANG")
          [ -n "$LOCALE_ARCHIVE" ] && binds+=(--setenv LOCALE_ARCHIVE "$LOCALE_ARCHIVE")
          # ~/.config is NOT bound wholesale: it holds browser profiles and
          # other secrets. List the dirs the agent actually needs.
          for p in "$HOME/.claude" "$HOME/.claude.json" "$HOME/.gitconfig" "$HOME/.local/share" \
                   "$HOME/.config/git" "$HOME/.config/zsh" "$HOME/.config/nvim" \
                   "$HOME/.config/tmux" "$HOME/.config/lf"; do
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
