{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    # for the *very* bleeding edge stuff, usually broken with stable releases...
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    # Add home-manager input
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, chaotic, ... }@inputs: {
    nixosConfigurations = {
      # the main home workstation
      deskmeat = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # Apply the custom overlay
          ({ config, pkgs, ... }: {
            nixpkgs.overlays = [ self.overlays.default ];
          })

          # Host-specific configurations
          ./hosts/deskmeat/configuration.nix

          # to add CachyOS kernels - https://www.nyx.chaotic.cx/
          chaotic.nixosModules.default
        ];
      };

      # Add other hosts here as needed
      # anotherhost = nixpkgs.lib.nixosSystem { ... };
    };

    # The overlay containing custom packages
    overlays.default = import ./overlays/default.nix;
  };
}
