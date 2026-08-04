# overlays/default.nix

{ inputs ? { } }: final: prev:

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

  # nixpkgs' python-unrar has pname "python-unrar" but ships a PyPI dist
  # named "unrar" - pythonMetadataCheckPhase can't find "python-unrar" and
  # fails. Pulled in transitively by gamma-launcher. That check is gated by
  # dontCheckPythonMetadata, not doCheck (which only guards the pytest phase).
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (pySelf: pySuper: {
      python-unrar = pySuper.python-unrar.overrideAttrs { dontCheckPythonMetadata = true; };
    })
  ];
}
