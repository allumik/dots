# Description of packages installed on Windows

## Pre-setup

To enable **WSL** (Canonical Ubuntu), run 

```pwsh
wsl --install -d Ubuntu
```

After installation run

```bash
sudo apt update -qq && sudo apt upgrade -y -qq
```

## Packages

Here we have the installer command which contains most of the necessary tools for development:

```bash
# essentials
sudo apt install -y -qq \
  neovim ripgrep silversearcher-ag fzf fd-find lf eza \
  build-essential ca-certificates wget curl git
  
# pixi
curl -fsSL https://pixi.sh/install.sh | sh
```

## Setup configuration files

For this, simply copy the `.conf` directory and the dotfiles (`.bashrc` etc) to your home directory.

For NeoVim configuration, you could use the `nixos/...` configuration here, but alternatively, you could set up a link to the preexisting Windows NeoVim configuration:

```bash
# create .config just to be sure
mkdir -p ~/.config/nvim
# create a link to the windows configuration
ln -s /mnt/c/Users/alvin/AppData/Local/nvim/init.lua ~/.config/nvim/init.lua
```

Same can be applied for other confs, for example:

```bash
# create those locations
mkdir -p ~/.config/euporie ~/.config/lf
# and create the links.
ln -s /mnt/c/Users/alvin/AppData/Roaming/lf/lfrc ~/.config/lf/lfrc
ln -s /mnt/c/Users/alvin/AppData/Local/euporie/config.json ~/.config/euporie/config.json
# etc...
```

## Setup SSH

Copy your keys to `~/.ssh/`, for example from your `C:\Users\<username>\.ssh`. Then run the following commands.

```bash
eval $(ssh-agent)

## if you added using file explorer, the permissions are too open
chmod -R 700 ~/.ssh/

## register your keys
ssh-add ~/.ssh/*
```

## Fix timedatectl issue by simulating `systemd`

**NB: Not used anymore, run dev env in containers anyways.**

We must specify the timezone, as the `timedatectl` function is not working when it is not possible to run services in WSL. For example `tidyverse` packages fail to load with no timezone defined. For this, we install `distrod` https://github.com/nullpo-head/wsl-distrod

```bash
# install and set it up
curl -L -O "https://raw.githubusercontent.com/nullpo-head/wsl-distrod/main/install.sh"
chmod +x install.sh
sudo ./install.sh install

# enable it
/opt/distrod/bin/distrod enable
```
