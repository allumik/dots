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

    # Lets a host boot as a WSL2 distribution on Windows
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Anthropic's official Claude Desktop Linux beta (.deb), repackaged.
    # Not in nixpkgs. nmcbride tracks the upstream apt repo closely (poeck's
    # flake sat on a 2-month-old build with a since-changed deb layout).
    claude-desktop = {
      url = "github:nmcbride/claude-desktop-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, stylix, ... }@inputs:
    let
      # Every host: the overlay, home-manager as a NixOS module, plus the
      # host's own module list.
      mkHost = system: modules: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          { nixpkgs.overlays = [ self.overlays.default ]; }
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # Move a pre-existing dotfile aside instead of failing activation
            # when home-manager wants to own it (e.g. the Plasma-era
            # ~/.config/kdeglobals). Without this the whole switch aborts.
            home-manager.backupFileExtension = "hm-bak";
          }
        ] ++ modules;
      };
    in {
      nixosConfigurations = {
        # the main home workstation
        deskmeat = mkHost "x86_64-linux" [ ./hosts/deskmeat.nix stylix.nixosModules.stylix ];

        # the old laptop workhorse who is still kicking
        oldlenno = mkHost "x86_64-linux" [ ./hosts/oldlenno.nix stylix.nixosModules.stylix ];

        # NixOS as a WSL2 distribution on the Windows box (pinnapro, a Surface
        # Pro 11), hence aarch64 - Snapdragon X Elite. Headless, so no stylix
        # module here: there is nothing graphical to theme.
        wsl-nix = mkHost "aarch64-linux" [ inputs.nixos-wsl.nixosModules.default ./hosts/wsl-nix.nix ];
      };

      # The overlay containing custom packages
      overlays.default = import ./overlays/default.nix { inherit inputs; };
    };
}
