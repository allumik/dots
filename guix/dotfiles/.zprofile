# Login zsh: zsh reads neither file on its own. /etc/profile sets up the
# system profile, ~/.profile the Guix Home one (and starts its shepherd).
emulate sh -c '. /etc/profile; . ~/.profile'
