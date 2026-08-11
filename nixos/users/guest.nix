# users/guest.nix
# Password-protected guest account, shared by both hosts: a normal persistent
# home running allu's desktop config, but credential stores are ephemeral -
# wiped when the last guest session ends (user@ drop-in) and again at boot
# (tmpfiles, for sessions that ended in a power cut).
# No password lives in this public repo: run `sudo passwd guest` once per
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
  wipe = pkgs.writeShellScript "wipe-guest-secrets"
    (lib.concatMapStringsSep "\n" (d: "rm -rf '/home/guest/${d}'") secretDirs);
in
{
  users.users.guest = {
    inherit uid;
    isNormalUser = true;
    description = "Guest";
    extraGroups = [ "networkmanager" ];
  };

  # Runs as the guest uid when user@1001.service stops, i.e. after the last
  # guest session logs out (and on shutdown, before filesystems unmount).
  systemd.services."user@${toString uid}" = {
    overrideStrategy = "asDropin";
    serviceConfig.ExecStopPost = "${wipe}";
  };

  # Boot-time backstop for the power-cut case (R = remove recursively).
  systemd.tmpfiles.rules = map (d: "R! /home/guest/${d}") secretDirs;

  # Same desktop as allu.
  home-manager.users.guest = {
    imports = [ ./allu/home.nix ];
    home.username = lib.mkForce "guest";
    home.homeDirectory = lib.mkForce "/home/guest";
  };
}
