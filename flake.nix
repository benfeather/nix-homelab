{
  description = "HomeLab NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      inherit (self) outputs;
    in
    {
      nixosConfigurations = {
        hydra = nixpkgs.lib.nixosSystem {
          modules = [
            # ./hardware-configuration.nix
            ./nixos/configuration.nix
          ];
          specialArgs = { inherit inputs outputs; };
        };
      };
    };
}
