{
  description = "NixOS configuration";

  inputs = {
    ## the stable channel
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    ## the unstable channel
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Add home-manager input
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { 
    self, 
    nixpkgs, 
    nixpkgs-unstable,
    home-manager, 
    plasma-manager,
    ... 
  }@inputs: {
    nixosConfigurations = {

      # the main home workstation
      deskmeat = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # Apply the custom overlay(s)
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ self.overlays.default ]; })

          # Host-specific configurations
          ./hosts/deskmeat/configuration.nix

          # Import Home-Manager configurations for users
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.sharedModules = [ plasma-manager.homeModules.plasma-manager ];
          }
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

          # Import Home-Manager configurations for users
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.sharedModules = [ plasma-manager.homeModules.plasma-manager ];
          }
        ];
      };

      # Add other hosts here
      # anotherhost = nixpkgs.lib.nixosSystem { ... };
    };

    # The overlay containing custom packages
    overlays.default = import ./overlays/default.nix { inherit inputs; };
  };
}
