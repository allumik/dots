# Windows-specific configurations

## Pre-setup

To enable **WSL** (Canonical Ubuntu), run:

```pwsh
wsl --install -d Ubuntu
```

`TODO: investigate NixOS WSL setup`

## WinGet

Simply, applications can be installed with the command `winget install -id <pkgId>`. To find the ID, use `winget search "name"`.

Here I have provided a quick minimal set of packages that should speed along with the search <-> install mantra in the `winget_pkgs.json` file. To reinstall those packages use this command `winget import -i winget_pkgs.json --accept-package-agreements --accept-source-agreements --ignore-unavailable`. 

Exporting is done with the command `winget export -o winget_pkgs.json` and by moving the file to dotfiles repo.

## Windows Terminal

You will have to use the Terminal's settings menu to locate the configuration file and then copy it from `win_terminal/settings.json` to that file.

## US-EE keyboard

US keyboard with Estonian letters - install with the installer.
[Or follow this guide to compile a new one, especially for ARM64 platform of Surface devices](https://github.com/johanson/US_EE)

Additionally, the `powertoys_bp` contains the keyboard mappings to duplicate the US-EE keyboard behaviour by mapping the EE letters to the right alt + {key} combinations.

## PowerToys

Simply install it and use their backup / restore functionality, restoring from teh `powertoys_bp/settings.json` file.

## VSCode

VSCode user configuration files are usually stored in `%APPDATA%\Code\User\`. So for using those configuration files, just dump them from `dots/conf_stash/vscode/*` to that location. Main plugins used are:

* VSCode Neovim by Alexey Svetliakov
* File Browser by Bodil Stokke
* Rainbow CSV by mechatroner
* modus-t by 月波 清火 (theme)

For full environment, install [Aporetic fonts](https://github.com/protesilaos/aporetic), set up Python and Pixi with their extensions, and the NeoVim configuration with headless configuration.

## Postgres server setup

Use the *postgres* user password saved from installation with winget to log into the shell with

```pwsh
gsudo psql -U postgres
```

And in the shell use command `\password` to reset the password for the postgres user.

Now you should be able to enter pgAdmin4 and setup necessary databases and users.
