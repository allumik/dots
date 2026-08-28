# WSL

The current setup is NixOS as a WSL2 distribution, driven by the `wsl-nix`
host in `nixos/`. The Ubuntu notes further down are kept only as a fallback
and are no longer maintained.

## NixOS under WSL

### Before you start

```pwsh
wsl --version    # need >= 2.4.4 for the .wsl installer
wsl --update
```

If WSL is not enabled at all: `wsl --install --no-distribution`, then reboot.

### Pick the right tarball — this is where it goes wrong

NixOS-WSL releases ship two assets, and the plain-named one is x86_64:

| Asset | For |
| --- | --- |
| `nixos.aarch64.wsl` | ARM machines — pinnapro (Surface Pro 11, Snapdragon X Elite) |
| `nixos.wsl` | x86_64 machines |

Take the wrong one on ARM and it installs perfectly happily, then dies the
instant you launch it:

```
Catastrophic failure
Error code: Wsl/Service/E_UNEXPECTED
```

There is no fix from the Windows side and no translation layer that helps —
WSL on ARM boots an ARM64 kernel and simply cannot execute an x86_64 rootfs.
Recover with `wsl --unregister NixOS` and install the right asset. (ARM assets
exist from release 2605.7.2 onward; before that the tarball had to be built by
hand inside an Ubuntu-on-ARM distro. See nix-community/NixOS-WSL#534.)

Download from https://github.com/nix-community/NixOS-WSL/releases/latest.

### Install

```pwsh
wsl --install --from-file .\nixos.aarch64.wsl
wsl -d NixOS
```

### First switch

You are now the tarball's stock `nixos` user, and this switch is about to move
the home directory out from under you — so build straight from GitHub instead
of cloning first:

```bash
sudo nixos-rebuild switch \
  --flake github:allumik/dots?dir=nixos#wsl-nix \
  --option experimental-features "nix-command flakes"
```

`?dir=nixos` is needed because the flake lives in a subdirectory. The
`--option` flag is harmless if the stock config already enables flakes. Expect
this one to take a while; later switches are fast.

It replaces the stock `/etc/nixos/configuration.nix` the tarball ships with.

### Restart the distro

Not optional. `defaultUser`, the hostname and `/etc/wsl.conf` only take effect
on a cold start:

```pwsh
wsl -t NixOS
wsl -d NixOS
```

You land as `allu` in `/home/allu`, hostname `wsl-nix`, with zsh, tmux, nvim,
lf and the `update-nixos` function from `users/allu/shell.nix`. `sudo` needs no
password — NixOS-WSL sets `security.sudo.wheelNeedsPassword = false`, which is
what makes a passwordless default user usable.

### Clone for ongoing work

```bash
git clone https://github.com/allumik/dots.git ~/Projects/dots
sudo nixos-rebuild switch --flake ~/Projects/dots/nixos#wsl-nix
```

Near-instant — everything is already in the store. After this the usual
`update-nixos` cycle applies.

`~/.ssh` is deliberately not managed by this repo, so set keys up by hand (see
the SSH section below, which still applies).

### Running x86_64 software

The distro is ARM, but `hosts/wsl-nix.nix` sets
`boot.binfmt.emulatedSystems = [ "x86_64-linux" ]`, so the kernel routes
x86_64 ELF binaries through qemu-user automatically. Nothing native gets
slower; only x86_64 processes are translated. The module also adds
`x86_64-linux` to `nix.settings.extra-platforms`, so nix can build and run
x86_64 derivations locally:

```bash
cat /proc/sys/fs/binfmt_misc/qemu-x86_64          # registration present
nix run nixpkgs#legacyPackages.x86_64-linux.hello # emulated x86_64 binary
```

For a whole x86_64 dev environment, point a devshell at
`nixpkgs.legacyPackages.x86_64-linux` rather than the default `pkgs`.

Two things to keep in mind:

- **Speed.** qemu-user interprets; it does not JIT-cache across runs. Heavy
  x86_64 workloads feel it. FEX-Emu (`pkgs.fex`) via a custom
  `boot.binfmt.registrations` entry is the upgrade path if it ever matters.
- **Disk.** The emulator is ~126 MiB in the store (37 MB download) and that
  part is fixed. The real cost is that qemu translates instructions, not
  libraries: every x86_64 program pulls its own complete x86_64 closure — a
  separate glibc and everything above it. `nix.optimise.automatic` cannot
  dedupe across architectures, so budget each x86_64 workload as a full second
  install of that workload.

If something only needs *building* as x86_64 rather than running
interactively, deskmeat as a remote builder over the tailnet skips both the
emulator and the duplicate closure.

### Maintenance

Daily gc with `--delete-older-than 7d` comes from `hosts/base.nix`, but the
ext4 VHDX backing the nix store only ever grows. Hand the space back to
Windows with:

```pwsh
wsl --manage NixOS --set-sparse true
```

### Do not remove `wsl.enable`

`wsl.enable = true` in `hosts/wsl-nix.nix` is what puts the WSL entrypoint in
the generated system. Drop it, switch, and the distro stops booting with
`wsl --unregister` as the only way out.

Likewise `wsl.interop.register = true` has to stay as long as any binfmt
registration exists: systemd-binfmt rewrites the whole table once NixOS owns
it, and without re-registering the handler, running `.exe` files from inside
the distro silently stops working — including the `wv` and `cdwin` aliases.

---

## Legacy: Ubuntu under WSL

Superseded by the NixOS setup above. Kept for the odd case where a
plain Debian-family distro is easier.

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
