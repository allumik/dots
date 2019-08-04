# $HOME/.profile

#Set our umask
umask 025

# set capslock as escape - lifesaver!
setxkbmap -option caps:swapescape

# Termcap is outdated, old, and crusty, kill it.
unset TERMCAP

# Man is much better than us at figuring this out
unset MANPATH

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists with subfolders
if [ -d "$HOME/.bin/" ] ; then
    PATH="$HOME/.bin/*/:$HOME/.bin/:$PATH"
fi

# Set our default path
PATH="/usr/local/sbin:/usr/local/bin:/usr/bin/core_perl:/usr/bin:$HOME/.config/bspwm/panel:$HOME/.bin"
export PANEL_FIFO="/tmp/panel-fifo"
export XDG_CONFIG_HOME="$HOME/.config"
export BSPWM_SOCKET="/tmp/bspwm-socket"
#export PANEL_HEIGHT=25
export XDG_CONFIG_DIRS=/usr/etc/xdg:/etc/xdg
export EDITOR=nvim
export ALTERNATE_EDITOR=nvim
export VISUAL="emacsclient -n"
export GUI_EDITOR="emacsclient -n"
export BROWSER=google-chrome-stable
export TERMINAL=kitty
export QT_QPA_PLATFORMTHEME="qt5ct"
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"

# Load profiles from /etc/profile.d
if test -d /etc/profile.d/; then
	for profile in /etc/profile.d/*.sh; do
		test -r "$profile" && . "$profile"
	done
	unset profile
fi

# Source global bash config
if test "$PS1" && test "$BASH" && test -r /etc/bash.bashrc; then
	. /etc/bash.bashrc
fi
