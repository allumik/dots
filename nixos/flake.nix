{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # for the bleeding edge stuff
    # nixpkgs-unstable.url = "github:nixos/nixpkgs/staging";

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
            ]; 
          })

          # Host-specific configurations
          ./hosts/deskmeat/configuration.nix
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
