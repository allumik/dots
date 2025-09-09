# Description of packages installed on Windows

## Pre-setup

To enable **WSL** (Canonical Ubuntu), run 

```pwsh
wsl --install -d Ubuntu
```

Installing **chocolatey** is described in [this guide](https://chocolatey.org/install)


## Windows Store

The Windows Store applications can be installed with the command `winget install -Id <pkgId>`

For example, `pkgs_min.json` has those apps:

```
GIMP.GIMP
Google.Chrome
Microsoft.Office
Microsoft.PowerToys
Google.Drive
9PFPFK4DJ1S6 # digidoc4

Spotify.Spotify
SlackTechnologies.Slack
WhatsApp.WhatsApp
Discord.Discord
Zoom.Zoom
Microsoft.Skype
Microsoft.Teams

JetBrains.Toolbox
VMware.WorkstationPlayer
Microsoft.VisualStudioCode
WinSCP.WinSCP

Microsoft.PowerShell
Git.Git
GitHub.GitHubDesktop
Docker.DockerDesktop
# winget installation of R has proven to work better than chocolatey
RProject.R -v 4.1.3 # 4.2.0 > does not work with electricShine yet
RProject.Rtools -v 4.0 # compatible with < 4.2.0, as opposed to -v 4.2

VideoLAN.VLC
Audacity.Audacity

JanDeDobbeleer.OhMyPosh
```

Or use a generated JSON file (`./confs/pkgs_min.json`) and run a command `winget import -i pkgs_min.json --accept-package-agreements --accept-source-agreements --ignore-unavailable`

*Exporting is done with the command `winget export -o pkgs.json` and move the file to dotfiles repo.*


## Chocolatey

After installing chocolatey restart the shell and at first install `gsudo`: `choco install -y gsudo`. This enables *sudo-like* behaviour in the `pwsh` shell.

Then restart shell and use the command `gsudo choco install -y <pkgsName>` to install:

```
neovim
postgresql
pgadmin4
pandoc
python3
nodejs-lts
yarn
ripgrep

tjs # jaspersoft studio
```

But as with the `winget`, it is more convinient to use exported conf file (`chocoPkgs.config`) for installation. For this, the command would be `gsudo choco install -y chocoPkgs.config`.

*Exporting is done via command `choco export -o="'chocoPkgs.config'"`.*

**Don't forget to save the postgres user password!**

## Unlisted applications

* Facebook Messenger standalone application
* US keyboard with Estonian letters - install with installer in `./configs/`

## Postgres server setup

Use the *postgres* user password saved from installation with chocolatey to log into the shell with

```pwsh
gsudo psql -U postgres
```

And in the shell use command `\password` to reset the password for the postgres user.

Now you should be able to enter pgAdmin4 and setup necessary databases and users.

## Other comments

VSCode user configuration files are in `C:\Users\alvin\AppData\Roaming\Code\User`.

Make a **neovide** shortcut with flag `neovide --wsl`.

TODO: postgres setup and database creation