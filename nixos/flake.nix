{
  description = "NixOS configuration";

  inputs = {
    ## the stable channel
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    ## the (usual) unstable channel
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Add home-manager input
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Unified theming across GTK/Qt/fuzzel/waybar
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Sandboxing helper for running packages with bubblewrap
    nix-bubblewrap = {
      url = "github:fgaz/nix-bubblewrap";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Terminal multiplexer for AI coding agents
    herdr = {
      url = "github:ogulcancelik/herdr";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    stylix,
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
          ./hosts/deskmeat.nix

          # Unified GTK/Qt/fuzzel/waybar theming
          stylix.nixosModules.stylix

          # Import Home-Manager configurations for users
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
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
          ./hosts/oldlenno.nix

          # Unified GTK/Qt/fuzzel/waybar theming
          stylix.nixosModules.stylix

          # Import Home-Manager configurations for users
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
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
