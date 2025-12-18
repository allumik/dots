# overlays/default.nix

self: super:

{
  # Override for conda to include `which`
  # !This is a temporary fix, prolly fixed in 25.11, search "nixpkgs conda which" for more info
  # conda = super.conda.override {
    # extraPkgs = [ super.which ];
  # };

  # This adds a new package 'vis-unstable'
  vis-git =
    let
      # Re-define luaEnv based on 'super' (the previous nixpkgs snapshot)
      luaEnv = super.lua.withPackages (ps: [ ps.lpeg ]);
    in
    # Use overrideAttrs to modify the existing 'vis' package from 'super'
    super.vis.overrideAttrs (oldAttrs: rec {
      pname = "vis-git";
      
      # This version string is just for informational purposes
      version = "master-git";

      # Override the source to point to the master branch
      src = super.fetchFromGitHub {
        owner = "martanne";
        repo = "vis";
        rev = "a730d3433ff0afc517eae8ddf4cd80997a9cd2a1"; # or "master"
        hash = "sha256-U4r4Vr32mYOXAaT1sYPOHeKlToq9t3c5OYq/ssRTqQc=";
      };

      # Re-define postInstall to use the correct lua version from 'super'
      # This is necessary because the luaEnv is built against 'super'
      postInstall = ''
        wrapProgram $out/bin/vis \
          --prefix LUA_CPATH ';' "${luaEnv}/lib/lua/${super.lua.luaversion}/?.so" \
          --prefix LUA_PATH ';' "${luaEnv}/share/lua/${super.lua.luaversion}/?.lua" \
          --prefix VIS_PATH : "\$HOME/.config:$out/share/vis"
      '';

      # Update meta description
      meta = oldAttrs.meta // {
        description = "Vim like editor (unstable git version)";
      };
    });

  antigravity = super.stdenv.mkDerivation rec {
    pname = "antigravity";
    version = "1.11.14";

    src = super.fetchurl {
      url = "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.11.14-5763785964257280linux-x64/Antigravity.tar.gz";
      # Replace with actual sha256 after first run
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };

    nativeBuildInputs = with super; [
      autoPatchelfHook
      makeWrapper
    ];

    buildInputs = with super; [
      alsa-lib
      at-spi2-atk
      at-spi2-core
      cairo
      cups
      dbus
      expat
      gdk-pixbuf
      glib
      gtk3
      libdrm
      libxkbcommon
      mesa
      nspr
      nss
      pango
      systemd
      xorg.libX11
      xorg.libXcomposite
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXrandr
      xorg.libxcb
      xorg.libxkbfile
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin $out/opt/antigravity
      cp -r * $out/opt/antigravity

      ln -s $out/opt/antigravity/antigravity $out/bin/antigravity

      runHook postInstall
    '';

    meta = with super.lib; {
      description = "Google Antigravity App";
      homepage = "https://google.com";
      platforms = [ "x86_64-linux" ];
      license = licenses.unfree;
    };
  };
}
