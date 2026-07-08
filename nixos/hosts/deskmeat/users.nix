{ config, lib, pkgs, ... }:

{
  ## User accounts
  users.users.allu = {
    isNormalUser = true; # dunno man
    description = "Alvin Meltsov";
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" "podman" ];
  };
  home-manager.users = {
    # Add other users here

    # brave/foot/syncthing/tailscale-systray etc. are all configured in
    # users/allu/confs/desktop.nix and theme.nix - this used to also carry
    # Plasma-specific power/lock config (programs.plasma.powerdevil/
    # kscreenlocker) from when this host ran Plasma, which doesn't apply to
    # niri and doesn't exist without plasma-manager imported.
    allu = {
      imports = [ ../../users/allu/home.nix ];

      # Two-way sync of ~/Drive with a "Drive" folder on Google Drive.
      # One-time manual setup after switching (not declarable - OAuth):
      #   rclone config          # create a remote named "gdrive", type drive
      #   rclone bisync ~/Drive gdrive:Drive --resync   # establish baseline
      # After that the timer below keeps them in sync unattended.
      home.packages = [ pkgs.rclone ];
      home.file."Drive/.keep".text = "";

      systemd.user.services.rclone-drive-bisync = {
        Unit.Description = "Bisync ~/Drive with Google Drive";
        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.rclone}/bin/rclone bisync %h/Drive gdrive:Drive --resilient";
        };
      };

      systemd.user.timers.rclone-drive-bisync = {
        Unit.Description = "Periodic Google Drive bisync";
        Timer = {
          OnBootSec = "5m";
          OnUnitActiveSec = "10m";
        };
        Install.WantedBy = [ "timers.target" ];
      };
    };
  };
}
