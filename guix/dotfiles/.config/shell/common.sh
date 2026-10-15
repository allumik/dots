# Aliases and functions shared by bash and zsh; sourced from both rc files.

alias cp='cp -i'          # confirm before overwriting something
alias df='df -h'          # human-readable sizes
alias free='free -m'      # show sizes in MB
alias more='less'
alias ls='ls --color=auto'
alias la='ls -A'
alias ll='eza -alF'
alias tux='tmux new-session -A -s main'
alias of='xdg-open "$(fzf --preview "bat {}")"'
alias es='$EDITOR "$(fzf --preview "bat {}")"'

# Pull, re-pin and reconfigure deskmeat from this repo's guix/ tree.
update-guix() {
  local dir=${1:-$HOME/Projects/dots/guix}
  guix pull -C "$dir/channels.scm" &&
    guix describe -f channels > "$dir/channels-lock.scm" &&
    sudo guix time-machine -C "$dir/channels-lock.scm" -- \
      system reconfigure -L "$dir/modules" "$dir/deskmeat.scm"
}

# claude in a bubblewrap sandbox: cwd, Claude Code state, git identity, host
# tools and network are visible; the rest of $HOME is not.
# NB: loop var is `p`, not `path` -- in zsh `path` is tied to $PATH.
claudy() {
  # No args: resume this directory's latest session, if it has one.
  # claude keys sessions by cwd with non-alphanumerics mapped to `-`.
  [ $# -eq 0 ] && [ -n "$(find "$HOME/.claude/projects/${PWD//[^a-zA-Z0-9]/-}" -maxdepth 1 -name '*.jsonl' -print -quit 2>/dev/null)" ] && set -- --continue
  # /gnu/store plus the profile symlink chains (/run/current-system,
  # /var/guix/profiles behind ~/.guix-home) give the sandbox the same PATH
  # as outside; bwrap passes the environment through unchanged.
  # /bin/sh and /usr/bin/env: hooks posix_spawn the former, shebangs use the latter.
  local binds=(
    --unshare-all --share-net --die-with-parent
    --proc /proc --dev /dev --tmpfs /tmp
    --ro-bind /gnu/store /gnu/store
    --ro-bind /etc /etc
    --ro-bind /run/current-system /run/current-system
    --ro-bind /var/guix/profiles /var/guix/profiles
    --ro-bind /bin /bin --ro-bind /usr/bin /usr/bin
    --bind "$PWD" "$PWD"
  ) p
  # GPU: /dev/dri is Vulkan/GL, /dev/kfd is ROCm compute, found through /sys.
  # These must stay after --dev /dev.
  for p in /dev/dri /dev/kfd; do
    [ -e "$p" ] && binds+=(--dev-bind "$p" "$p")
  done
  [ -e /sys ] && binds+=(--ro-bind /sys /sys)
  # ~/.config is NOT bound wholesale: it holds browser profiles and
  # other secrets. List the dirs the agent actually needs.
  for p in "$HOME/.guix-home" "$HOME/.claude" "$HOME/.claude.json" "$HOME/.gitconfig" \
           "$HOME/.local/share" "$HOME/.config/git" "$HOME/.config/nvim" \
           "$HOME/.config/tmux" "$HOME/.config/lf" "$HOME/.config/shell"; do
    [ -e "$p" ] && binds+=(--bind "$p" "$p")
  done
  bwrap "${binds[@]}" -- claude "$@"
}

# tmux position: window/windows|session/sessions, e.g. 1/3|1/2.
# window: active window's ordinal among this session's windows.
# session: $TMUX's third comma-field is our session-id number;
# list-sessions is name-sorted so NR is a stable ordinal.
_tmux_pos() {
  local w=$(tmux list-windows -F "#{window_active}" 2>/dev/null \
    | awk '$0==1{i=NR} END{print i"/"NR}')
  local s=$(tmux list-sessions -F "#{session_id}" 2>/dev/null \
    | awk -v c="${TMUX##*,}" 'substr($0,2)==c{i=NR} END{print i"/"NR}')
  printf '%s|%s' "$w" "$s"
}
