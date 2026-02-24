{
  description = "NixOS configuration";

  inputs = {
    ## the stable channel
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    ## the (usual) unstable channel
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    ## for the bleeding edge stuff
    # nixpkgs-staging.url = "github:nixos/nixpkgs/staging";
    ## for fixing some working version
    # nixpkgs.url = "github:NixOS/nixpkgs/2343bbb58f99267223bc2aac4fc9ea301a155a16";

    # Add home-manager input
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  # nixpkgs-unstable,
  outputs = { 
    self, 
    nixpkgs, 
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
    overlays.default = import ./overlays/default.nix; # { pkgs-unstable = nixpkgs-staging; };
  };
}
