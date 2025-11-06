{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # for the *kinda* bleeding edge stuff
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    # for the *very* bleeding edge stuff
    # nixpkgs-unstable.url = "github:nixos/nixpkgs/staging";

    # Nifty steam wrapper
    millennium.url = "git+https://github.com/SteamClientHomebrew/Millennium";

    # Add home-manager input
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # nixpkgs-unstable,
  outputs = { 
    self, 
    nixpkgs, 
    home-manager, 
    chaotic, 
    ... 
  }@inputs: {
    nixosConfigurations = {

      # the main home workstation
      deskmeat = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # Apply the custom overlay(s)
          ({ config, pkgs, ... }: { 
            nixpkgs.overlays = [ 
              self.overlays.default 
              inputs.millennium.overlays.default
            ]; 
          })

          # Host-specific configurations
          ./hosts/deskmeat/configuration.nix

          # to add CachyOS kernels - https://www.nyx.chaotic.cx/
          chaotic.nixosModules.default
        ];
      };


      # the old laptop workhorse who is still kicking
      oldlenno = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # Apply the custom overlay
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ self.overlays.default ]; })

          # Host-specific configurations
          ./hosts/oldlenno/configuration.nix
        ];
      };

      # Add other hosts here
      # anotherhost = nixpkgs.lib.nixosSystem { ... };
    };

    # The overlay containing custom packages
    overlays.default = import ./overlays/default.nix; # { pkgs-unstable = nixpkgs-unstable; };
  };
}
