# overlays/default.nix

{ }: final: prev:

let
  pyOverlay = import ./py { pkgs = final; lib = final.lib; replaceVars = final.replaceVars; };
in
{
  # https://github.com/NixOS/nixpkgs/issues/513245
  openldap = prev.openldap.overrideAttrs {
    doCheck = !prev.stdenv.hostPlatform.isi686;
  };

  # Feeds gamma-launcher/euporie/etc. (overlays/py) into python313.pkgs, so
  # both `pkgs.python313.withPackages` (used by py-env) and the top-level
  # alias below see them.
  python313 = prev.python313.override (old: {
    packageOverrides = final.lib.composeExtensions (old.packageOverrides or (_: _: { })) pyOverlay;
  });

  gamma-launcher = final.python313.pkgs.gamma-launcher;
}
