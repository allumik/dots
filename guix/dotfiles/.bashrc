# Non-interactive shells (scp, guix shell commands) stop here.
[[ $- == *i* ]] || return

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ "$color_prompt" = yes ]; then
    PS1=' \[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1=' \u@\h:\w\$ '
fi
unset color_prompt

. ~/.config/shell/common.sh
[ -n "$TMUX" ] && PS1="[tmux \$(_tmux_pos)]$PS1"

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*|foot*)
    PS1="\[\e]0;\u@\h: \w\a\]$PS1"
    ;;
esac

# enable color support of ls
if command -v dircolors >/dev/null; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi
