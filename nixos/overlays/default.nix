# overlays/default.nix

{ inputs }: self: super:

{
  # https://github.com/NixOS/nixpkgs/issues/513245
  openldap = super.openldap.overrideAttrs {
    doCheck = !super.stdenv.hostPlatform.isi686;
  };

  antigravity-cli = (import inputs.nixpkgs-unstable {
    inherit (super) system;
    config.allowUnfree = true;
  }).antigravity-cli;
}
