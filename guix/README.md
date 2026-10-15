# Guix System config for deskmeat

Alternative to `nixos/` for deskmeat (oldlenno stays on NixOS). Guix is the
glue: it installs packages, runs services and links config files into place.
The configs themselves are each tool's native file.

```
guix/
  channels.scm        guix + nonguix, unpinned
  channels-lock.scm   pinned commits (guix describe -f channels)
  deskmeat.scm        operating-system: boot, disks, users, services, packages
  home.scm            Guix Home for allu and jane; deskmeat.scm loads it
  modules/allu/       personal channel (-L guix/modules): claude-code,
                      tailscale, chicago95
  niri.kdl            Guix-only tail appended to the shared niri config
  nftables.conf       firewall
  dotfiles/           native configs, mirrors $HOME (waybar, fuzzel, foot,
                      mako, swayidle, tmux, zsh, bash, gtk, kdeglobals,
                      portals, pipewire, ~/.local/bin scripts, .desktop files)
```

Shared with NixOS and placed unchanged from `nixos/users/allu/confs/`:
`init.lua`, `lfrc`, `niri.kdl`, `waycorner.toml`, `claude-settings.json`,
`emojis.txt`.

## Commands

Run from the repo root. Every system and home command goes through the
lock file, so builds are reproducible from a clean checkout.

```sh
guix pull -C guix/channels.scm                       # update inputs
guix describe -f channels > guix/channels-lock.scm   # re-pin
guix time-machine -C guix/channels-lock.scm -- system build -L guix/modules guix/deskmeat.scm
sudo guix time-machine -C guix/channels-lock.scm -- system reconfigure -L guix/modules guix/deskmeat.scm
guix time-machine -C guix/channels-lock.scm -- home reconfigure -L guix/modules guix/home.scm  # standalone, allu only
guix system roll-back      # or pick an older generation in GRUB
guix gc -d 30d             # by hand; a daily shepherd timer does 7d
```

The `update-guix` shell function does pull + re-pin + reconfigure in one go.

## Install (dual boot next to NixOS)

1. Shrink a partition or use free space, create an ext4 partition and label
   it `guix-root` (`e2label /dev/nvme0n1pX guix-root`). The ESP (`D63B-498A`),
   swap and data disks are shared with NixOS and referenced by UUID.
2. Boot the Guix installer, mount the new root at `/mnt` and the ESP at
   `/mnt/boot/efi`, `herd start cow-store /mnt`.
3. Authorize nonguix substitutes for the install (the config itself does it
   afterwards): see the nonguix README.
4. `guix time-machine -C guix/channels-lock.scm -- system init -L guix/modules guix/deskmeat.scm /mnt`
5. GRUB now owns the ESP boot order; "NixOS" in its menu chainloads
   systemd-boot.

## One-time manual steps

- `sudo passwd allu`, `sudo passwd jane` (no passwords in this repo).
- `sudo tailscale up`; tailscaled starts at boot, DNS override stays off.
- Flatpaks (no Guix package, or Guix's would need FHS runners):
  ```sh
  flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  flatpak install --user flathub com.brave.Browser com.discordapp.Discord net.lutris.Lutris \
    com.visualstudio.code ee.ria.qdigidoc4 dev.lizardbyte.app.Sunshine
  ```
- `cargo install waycorner nirius chameleos` (niri helpers, not in Guix;
  `~/.cargo/bin` is on PATH). Needs a `rust` + `gcc-toolchain` shell:
  `guix shell rust rust:cargo gcc-toolchain pkg-config wayland -- cargo install ...`
- pixi: `curl -fsSL https://pixi.sh/install.sh | sh` (self-updating; also
  for quarto, gamma-launcher, west, nextflow).
- rclone: `rclone config` (remote `gdrive3`), `mkdir ~/Drive`,
  `rclone bisync ~/Drive gdrive3:Documents --resync`. The timer runs every
  10 minutes after that.
- Proton-GE (nonguix `protonup`): `protonup -d ~/.local/share/guix-sandbox-home/.steam/root/compatibilitytools.d`.

## Changed or dropped compared to nixos/

- Kernel: nonguix `linux-lts` instead of zen (D10). scx, lact, ROCm host
  stack, nix-ld, nix-bubblewrap, cachix, stylix: dropped (D3, D4, D9).
  ROCm compute runs in podman with `--device /dev/kfd --device /dev/dri`.
- Theme: stylix's humanoid-light palette and fonts are written out in each
  config file (O6, hard-coded).
- systemd user units (mako, swayidle, wlsunset, nm-applet, polkit agent,
  cliphist, tailscale tray) are spawned by niri (`niri.kdl` here). rclone and
  podman prune are home shepherd timers. `systemctl suspend|reboot|poweroff`
  became `loginctl ...`.
- swayosd: not in Guix. `~/.local/bin/swayosd-client` maps the volume keys
  to `wpctl` (no OSD).
- oh-my-zsh: not in Guix. The nicoulaj prompt is rebuilt with `vcs_info`;
  fast-syntax-highlighting became zsh-syntax-highlighting; the
  extract/gitfast/gh/tmux plugins and zsh-nix-shell are gone.
- tmux plugins sensible/yank/open: sensible's settings inlined, yank is a
  copy-mode binding to `wl-copy`, open dropped.
- `claudy` uses plain `bwrap` instead of nix-bwrap.
- Sunshine: flatpak. Its docs say the flatpak has no KMS capture, only XDG
  portal capture on Wayland; niri supports that portal through
  xdg-desktop-portal-gnome. Firewall ports stay open.
- Not packaged anywhere, dropped: veracrypt, omnissa-horizon-client,
  claude-desktop (O8), scarlett2, quickemu, podman-tui, nvtop, fontpreview
  (and its "Font Viewer" menu entry), xan, retry, gdrive3, tre (`tree`
  instead), Vista/vt323/fixedsys/merriweather/powerline fonts, r-dotenv.
- transmission is the GTK build, thunderbird is icedove, wakeonlan is
  `wol`.
- jane: secrets are wiped by pam_exec when her greetd session closes and
  again at boot. Brave's flatpak profile is in the wipe list.
- matplotlibrc (webagg on 0.0.0.0) is not ported yet; copy it from
  `nixos/users/allu/home.nix` into `dotfiles/.config/matplotlib/` if wanted.
