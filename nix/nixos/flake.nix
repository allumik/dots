{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    catppuccin.url = "github:catppuccin/nix";

    # other inputs...
  };

  outputs = 
    inputs@{ 
      nixpkgs, 
      home-manager,
      ... 
    }: 
    {
      nixosConfigurations = {
        deskmeat = nixpkgs.lib.nixosSystem {
          modules = [
            ./configuration.nix

            # other modules...
          ];
        };
      };
  };
}
