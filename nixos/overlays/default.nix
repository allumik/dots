# overlays/default.nix

{ pkgs-unstable }: self: super: 

let 
  unstablePkgs = import pkgs-unstable {
    system = super.stdenv.hostPlatform.system;
    # If you need unfree packages from unstable, you must also allow them here.
    config.allowUnfree = true;
  };
in 
{
  # Override for conda to include `which`
  # !This is a temporary fix, prolly fixed in 25.11, search "nixpkgs conda which" for more info
  conda = super.conda.override {
    extraPkgs = [ super.which ];
  };

  # override some packages from the overlay, hope that it does not cause a full system rebuild
  # lact = unstablePkgs.lact;
}
