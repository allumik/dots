# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/home/allu/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="nicoulaj"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="mm/dd/yyyy"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git extract web-search zsh-syntax-highlighting fzf)

source $ZSH/oh-my-zsh.sh


#### User configuration


# define TZ for apps
export TZ="Europe/Tallinn"

# export ALTERNATE_EDITOR=""
export EDITOR=nvim  # $EDITOR opens in terminal
export VISUAL=code  # $VISUAL opens in GUI mode


## N^3 options
export NNN_OPENER="/usr/bin/wslview"
# automatically cd into directory
export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
export NNN_FIFO="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/nnn.fifo"
# add an depth indicator
[ -n "$NNNLVL" ] && PS1="!~$NNNLVL $PS1"
# plugin selector
export NNN_PLUG='t:fzcd;d:diffs;x:preview-tui;v:imgview;e:suedit;.:dragdrop'
# put dotfiles first!
export LC_COLLATE="C"
# functions:
nn () {
    # Block nesting of nnn in subshells
    if [ -n $NNNLVL ] && [ "${NNNLVL:-0}" -ge 1 ]; then
        echo "nnn is already running"
        return
    fi

    export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

    nnn "$@"

    if [ -f "$NNN_TMPFILE" ]; then
            . "$NNN_TMPFILE"
            rm -f "$NNN_TMPFILE" > /dev/null
    fi
}



## FZF options
export FZF_DEFAULT_COMMAND="fdfind -H"
# for aliases and using "batd"
FZF_PREVIEW=(--preview 'batd --color=always --style=numbers --line-range=:500 {}')


# use shortcuts
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^H' backward-kill-word
bindkey '^[[3;5~' kill-word


# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Add some PATH's to the PATH
export PATH=$HOME/.bin:/usr/local/bin:$PATH
export PATH=$HOME/git/qmk_firmware/bin:$HOME/.local/bin:$PATH
export PATH=$HOME/.local/bin/:$HOME/.emacs.d/bin:$HOME/miniconda3/bin:$PATH
export PATH=$HOME/.cargo/bin/:$PATH


# Aliases here because i'm too lazy to source "aliases" file
alias cp="cp -i"     # confirm before overwriting something
alias df='df -h'     # human-readable sizes
alias free='free -m' # show sizes in MB
alias np='nano -w PKGBUILD'
alias more=less
alias sn='sudo -E nnn -dH'
# alias python='python3'
alias ll='exa -alF'
alias la='ls -A'

alias unmount='umount -f ~/mntpnt'
alias tux='tmux new-session -A -s main'
alias pac='sudo pacman'
alias cdf='cd "$(dirname "$(fzf $FZF_PREVIEW)")"'
alias of='wslview "$(fzf $FZF_PREVIEW)"'
# edit commands
alias es='$EDITOR "$(fzf $FZF_PREVIEW)"'
alias wv=wslview

