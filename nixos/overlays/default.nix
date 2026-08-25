# overlays/default.nix

{ inputs ? { } }: final: prev:

{
  # Upstream still refers to pkgs.tcllib/pkgs.tclx, which nixpkgs renamed to
  # pkgs.tclPackages.{tcllib,tclx} in 2025-10-27; shim them back in for the build.
  nix-bubblewrap = import "${inputs.nix-bubblewrap}/default.nix" {
    pkgs = final // { inherit (final.tclPackages) tcllib tclx; };
  };

  # Chicago95's index.theme has no Inherits= line, so every icon name it lacks
  # (VS Code and most third-party apps) renders blank instead of falling back.
  # Append a fallback chain; papirus-icon-theme is installed alongside it.
  chicago95 = prev.chicago95.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      sed -i '/^Name=Chicago95$/a Inherits=Papirus-Light,Papirus,hicolor' \
        $out/share/icons/Chicago95/index.theme
    '';
  });

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
