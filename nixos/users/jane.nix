# users/jane.nix
# Password-protected account for Jane, shared by both hosts: a normal persistent
# home running allu's desktop config, but credential stores are ephemeral -
# wiped when her last session ends (user@ drop-in) and again at boot
# (tmpfiles, for sessions that ended in a power cut).
# No password lives in this public repo: run `sudo passwd jane` once per
# machine (users are mutable); until then the account is locked.
{ config, lib, pkgs, ... }:

let
  uid = 1001; # pinned so the user@<uid> drop-in below can target the instance
  # Runtime secret stores only - none are home-manager-managed, so wiping is
  # safe: gnome-keyring DBs, ssh keys/known_hosts/authorized_keys, gpg, and
  # the brave profile (cookies/tokens/saved logins - remove from this list if
  # brave state should survive instead).
  # ponytail: allowlist, not exhaustive - apps stashing tokens in odd paths
  # survive; extend the list when one turns up.
  secretDirs = [
    ".local/share/keyrings"
    ".ssh"
    ".gnupg"
    ".config/BraveSoftware"
  ];
  wipe = pkgs.writeShellScript "wipe-jane-secrets"
    (lib.concatMapStringsSep "\n" (d: "rm -rf '/home/jane/${d}'") secretDirs);
in
{
  users.users.jane = {
    inherit uid;
    isNormalUser = true;
    description = "Jane";
    extraGroups = [ "networkmanager" ];
  };

  # Runs as jane's uid when user@1001.service stops, i.e. after the last
  # session of hers logs out (and on shutdown, before filesystems unmount).
  systemd.services."user@${toString uid}" = {
    overrideStrategy = "asDropin";
    serviceConfig.ExecStopPost = "${wipe}";
  };

  # Boot-time backstop for the power-cut case (R = remove recursively).
  systemd.tmpfiles.rules = map (d: "R! /home/jane/${d}") secretDirs;

  # Same desktop as allu (home.nix takes username/homeDirectory from the
  # NixOS user it is imported for).
  home-manager.users.jane = {
    imports = [ ./allu/home.nix ./allu/desktop.nix ];
  };
}
