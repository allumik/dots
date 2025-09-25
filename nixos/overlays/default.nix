# overlays/default.nix

{ nixpkgs-master }: self: super: 

let 
  masterPkgs = import nixpkgs-master {
    system = super.stdenv.hostPlatform.system;
    # If you need unfree packages from master, you must also allow them here.
    config.allowUnfree = true;
  };
in 
{
  # Custom build for the aretext text editor
  # TODO: Submit a PR to nixpkgs and remove this overlay
  aretext = super.buildGoModule rec {
    pname = "aretext";
    version = "1.5.0";

    src = super.fetchFromGitHub {
      owner = "aretext";
      repo = "aretext";
      rev = "v${version}";
      sha256 = "sha256-pYU4wIrrVhGLyUKIsVBofxpsPyXvs1HIH/ioz9sTZ6I=";
    };

    vendorHash = "sha256-iLno+/raBA2u7c92FDP31DOw+vWAxgGpQgWWBr9HZs0=";

    nativeBuildInputs = [ super.gnumake ];

    ldflags = [ "-s" "-w" "-X main.version=${version}" ];

    meta = with super.lib; {
      description = "A minimalist text editor with Vim-compatible bindings";
      homepage = "https://github.com/aretext/aretext";
      license = licenses.gpl3Only;
      platforms = platforms.all;
    };
  };

  # Override for conda to include `which`
  # !This is a temporary fix, search "nixpkgs conda which" for more info
  conda = super.conda.override {
    extraPkgs = [ super.which ];
  };

  # override some packages from the overlay, hope that it does not cause a full system rebuild
  # rocmPackages = masterPkgs.rocmPackages;
}
