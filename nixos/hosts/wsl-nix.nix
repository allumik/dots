# hosts/wsl-nix.nix
# NixOS running as a WSL2 distribution on the Windows box. Headless by
# definition: imports base.nix only, never desktop.nix or stylix.nix - WSLg
# could technically launch GUI apps, but niri does not run under it.
# No hardware/bootloader/filesystem config here either; WSL supplies the
# kernel and rootfs. See windows/README.md for the one-time install.
{ lib, pkgs, ... }:

let
  # Follow https://github.com/NixOS/nixpkgs/issues/475732 for Python 3.14
  py-env = pkgs.python313.withPackages (ps: with ps; [
    pip setuptools
    numpy numba pandas scipy scikit-learn
    matplotlib seaborn altair ipykernel
  ]);
in
{
  imports = [
    ./base.nix # Shared headless config: nix/locale/CLI tools/ssh/gc
  ];

  ## Nixpkgs platform
  nixpkgs.hostPlatform = "x86_64-linux";

  # Without this the system builds as plain "nixos"; wsl.wslConf.network.hostname
  # defaults to this value, so it propagates into /etc/wsl.conf too.
  networking.hostName = "wsl-nix";

  wsl = {
    # Never remove: without it the generated system has no WSL entrypoint and
    # the distro stops booting, leaving `wsl --unregister` as the only way out.
    enable = true;
    defaultUser = "allu";
    useWindowsDriver = true; # /dev/dxg, so the host GPU is visible to CUDA
    startMenuLaunchers = true;
    # wsl.interop.includePath stays at its default (true) - the `wv`
    # (wslview) and `cdwin` aliases in users/allu/shell.nix need the Windows
    # PATH to be visible from inside the distro.
  };

  # Windows already listens on :22 for its own OpenSSH; a second sshd in the
  # distro is reachable only over the WSL NAT and just fights for the port.
  services.openssh.enable = lib.mkForce false;

  environment.systemPackages = [ py-env ];

  ## User accounts
  users.users.allu = {
    isNormalUser = true; # dunno man
    description = "Alvin Meltsov";
    extraGroups = [ "wheel" ];
  };
  home-manager.users.allu = {
    # No desktop.nix import on purpose - see users/allu/home.nix.
    imports = [ ../users/allu/home.nix ];
  };
}
