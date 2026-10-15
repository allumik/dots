# Interactive zsh. Plugins come from the Guix Home profile; oh-my-zsh is not
# packaged in Guix, so its nicoulaj theme is re-created below with vcs_info.
profile=$HOME/.guix-home/profile/share/zsh

HISTFILE=~/.zsh_history HISTSIZE=10000 SAVEHIST=10000
setopt extended_history share_history hist_ignore_dups hist_ignore_space

fpath=($profile/site-functions /run/current-system/profile/share/zsh/site-functions $fpath)
autoload -U compinit && compinit

source $profile/plugins/fzf-tab/fzf-tab.plugin.zsh
source $profile/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

export FZF_DEFAULT_OPTS='--height 40%'
export FZF_CTRL_T_OPTS="--preview 'bat {}'"
export FZF_ALT_C_OPTS="--preview 'bat {}'"
source <(fzf --zsh)

# nicoulaj: path relative to the repo root on the left, vcs info on the
# right, green/red end marker by last exit status, user@host only over ssh.
autoload -Uz vcs_info add-zsh-hook
add-zsh-hook precmd vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*:*' check-for-changes true
zstyle ':vcs_info:*:*' unstagedstr '!'
zstyle ':vcs_info:*:*' stagedstr '+'
zstyle ':vcs_info:*:*' actionformats '%S' '%r/%s/%b %u%c (%a)'
zstyle ':vcs_info:*:*' formats '%S' '%r/%s/%b %u%c'
zstyle ':vcs_info:*:*' nvcsformats '%~' ''
setopt prompt_subst  # so the $(...) and ${...} below re-run each render
PROMPT='%(?.%F{71}.%F{124})${SSH_TTY:+[%n@%m]}%B%30<..<${vcs_info_msg_0_%%.}%<<%(!.❯❯❯.❯)%b%f '
RPROMPT='%F{242}${vcs_info_msg_1_}%f'

source ~/.config/shell/common.sh
[[ -n "$TMUX" ]] && PROMPT="%F{cyan}[tmux \$(_tmux_pos)]%f $PROMPT"
# Stands in for fast-syntax-highlighting (not in Guix); must come last.
source $profile/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
unset profile
