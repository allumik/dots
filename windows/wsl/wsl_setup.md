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


## Extra preliminaries

Here we add several extra PPA repositories for more updated packages:

```bash
sudo add-apt-repository ppa:neovim-ppa/stable # neovim > 0.51
sudo add-apt-repository ppa:numix/ppa # icon theme
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


## Installed apt packages

Here we have the big installer which contains most of the necessary tools for development:

```bash
# essentials
sudo apt install -y -qq \
  build-essential devscripts wget curl git sassc \
  gfortran libblas-dev liblapack-dev \
  openssh-server sshfs ca-certificates \
  libxml2-dev libcurl4-openssl-dev libpng-dev libbz2-dev liblzma-dev \
  libfontconfig1-dev libssl-dev libssh-dev \
  python3 python3-pip \
  nodejs yarn npm zsh \
  meson libsystemd-dev pkg-config ninja-build git libdbus-1-dev libinih-dev \
  cmake pkg-config python3 \
  python3-gi python3-setuptools python3-stdeb dh-python python-all \
  python3-testresources \
  tmux neovim ripgrep silversearcher-ag fzf fd-find nnn

# some tools - exa
EXA_VERSION=$(curl -s "https://api.github.com/repos/ogham/exa/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
curl -Lo exa.zip "https://github.com/ogham/exa/releases/latest/download/exa-linux-x86_64-v${EXA_VERSION}.zip"
sudo unzip -q exa.zip bin/exa -d /usr/local
rm exa.zip

# some tools - oh-my-zsh
sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
# fix the damage done
mv ~/.zshrc ~/.zshrc.template
mv ~/.zshrc.pre-oh-my-zsh ~/.zshrc

# and plugin for oh-my-zsh
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting


# # graphical applications
# sudo apt install -y \
#   torbrowser-launcher transmission-gtk

# install themes for the GTK apps
sudo apt install -y -qq \
  gtk2-engines-murrine gtk2-engines-pixbuf sassc \
  numix-icon-theme-circle

# codecs, could also get installed with vlc
sudo apt install -y libavcodec-extra libdvd-pkg; sudo dpkg-reconfigure libdvd-pkg

# latex installer, if you need it
sudo apt install -y texlive texlive-font-utils texlive-pstricks-doc \
  texlive-base texlive-formats-extra texlive-lang-european texlive-metapost \
  texlive-publishers texlive-bibtex-extra texlive-latex-base \
  texlive-metapost-doc texlive-publishers-doc texlive-binaries \
  texlive-latex-base-doc texlive-science texlive-extra-utils \
  texlive-latex-extra texlive-science-doc texlive-fonts-extra \
  texlive-latex-extra-doc texlive-pictures texlive-xetex texlive-fonts-extra-doc \
  texlive-latex-recommended texlive-pictures-doc texlive-fonts-recommended \
  texlive-humanities texlive-lang-english texlive-latex-recommended-doc \
  texlive-fonts-recommended-doc texlive-humanities-doc texlive-luatex texlive-pstricks \
  perl-tk

# install some python stuff
python3 -m pip install -U \
  pip setuptools wheel \
  jupyter ipykernel ipython numpy \
  pandas seaborn plotly sympy \
  matplotlib scikit-learn opencv-python \
  radian
sudo apt install -y jupyter-notebook

```

Install Rust: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`



## Fonts

This setup requires a folder in the home directory - `.fonts` - where all the fonts for use are kept.

After creating this directory and populating it with fonts (I don't keep them in git), run:

```bash
# link the fonts folder in Windows, for example:
ln -s /mnt/c/Users/allu/.fonts ~/.fonts

# sync fonts
fc-cache -fv
```


## Install Qogir theme

1. Create a `.themes` folder. 
2. Download the theme `wget https://github.com/vinceliuice/Qogir-theme/archive/refs/tags/2022-04-29.zip`.
3. `unzip <zip> && cd <dir>`.
4. Run `./install.sh --theme ubuntu --logo ubuntu --tweaks image square round`.
5. Set the theme (and the Numix icon theme) with:

```bash
gsettings set org.gnome.desktop.interface gtk-theme "Qogir-Ubuntu-Dark"
gsettings set org.gnome.desktop.wm.preferences theme "Qogir-Ubuntu-Dark"
gsettings set org.gnome.desktop.interface icon-theme "Numix Circle"
gsettings set org.gnome.desktop.wm.preferences button-layout appmenu:minimize,maximize,close
```

## Setup configuration files

For this, simply copy the `.conf` directory and the dotfiles (`.bashrc` etc) to your home directory.

## Setup SSH

Copy your keys to `~/.ssh/`, for example from your `C:\Users\<username>\.ssh`. Then run the following commands.

```bash
eval $(ssh-agent)

## if you added using file explorer, the permissions are too open
chmod -R 700 ~/.ssh/

## register your keys
ssh-add ~/.ssh/*
```

### Setup tmux

This will require `.tmux.conf` at home directory. We will install a plugin manager **tpm** for the configuration and install further plugins.

```bash
# install tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# install plugins with tpm
~/.tmux/plugins/tpm/bin/install_plugins
```


## Install GPU drivers and tensorflow

**NB: not needed after Docker install**

~Follow the guide: https://docs.nvidia.com/cuda/wsl-user-guide/index.html#getting-started-with-cuda-on-wsl~

Actually this is outdated, when you install Docker on Windows and enable WSL2 support, the docker images will be automatically running from there.

Next we'll install tensorflow with keras and also pytorch. Those installers already contain necessary CUDA (for >8.6 GPU) packages.

```bash
pip install tensorflow

pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu113
```

## Install R and packages

Update the repo key and install the latest r-base

```bash
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
sudo apt update
sudo apt install -y --no-install-recommends r-base
```

After installing base R install some elementary packages for regular use, as written in file `r_packages.R`. For this, open R REPL and use the following command:

```r
# you can wrap it in R -e "..." for command line
install.packages(c(
    "devtools",
    "rlang",
    "renv",
    "png",
    "curl",
    "openssl",
    "ssh",
    "languageserver",
    "knitr",
    "BiocManager",
    "snow",

    "tidyverse",
    "ggplot2",
    "ggpubr",
    "ggvenn",
    "magrittr",
    "jsonlite",
    "knitr",
    "rmarkdown",
    "plotly",
    "tidymodels",
    "recipes",
    "glue",
    "patchwork",
    "feather",
    "foreach",
    "iterators",
    "reactable",
    "ggrepel",
    "heatmaply",
    "viridis",
    "RColorBrewer",
    "embed",
    "broom",
    "modelr",
    "statmod",
    "nFactors",
    "svglite",
    "devEMF",
    "kableExtra",
    "mltools",
    "showtext",
    "umap",
    "writexl",
    "Exact",
    "glmnet",
    "kernlab",
    "tictoc",
    "ranger",
    "vip",
    "pdp",
    "RcppTOML",
    "corrr"
))

BiocManager::install(c(
  "sva",
  "DESeq2",
  "pcaExplorer",
  "GenomicRanges",
  "biomaRt",
  "Glimma",
  "edgeR",
  "limma"
))
```