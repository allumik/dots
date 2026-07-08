# overlays/default.nix

{ inputs ? { } }: final: prev:

let
  pyOverlay = import ./py { pkgs = final; lib = final.lib; replaceVars = final.replaceVars; };
in
{
  # Upstream still refers to pkgs.tcllib/pkgs.tclx, which nixpkgs renamed to
  # pkgs.tclPackages.{tcllib,tclx} in 2025-10-27; shim them back in for the build.
  nix-bubblewrap = import "${inputs.nix-bubblewrap}/default.nix" {
    pkgs = final // { inherit (final.tclPackages) tcllib tclx; };
  };

  herdr = inputs.herdr.packages.${final.stdenv.hostPlatform.system}.default;
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
