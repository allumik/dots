# overlays/default.nix

{ }: self: super:

{
  # https://github.com/NixOS/nixpkgs/issues/513245
  openldap = super.openldap.overrideAttrs {
    doCheck = !super.stdenv.hostPlatform.isi686;
  };
}
