{
  description = "HomeLab NixOS Configuration";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
  };

  outputs =
    {
      home-manager,
      nixpkgs,
      self,
      vscode-server,
      ...
    }@inputs:
    let
      env = import ../utils/env.nix;
    in
    {
      nixosConfigurations = {
        hydra = nixpkgs.lib.nixosSystem {
          modules = [
            home-manager.nixosModules.home-manager
            vscode-server.nixosModules.default
            ./nixos/configuration.nix
          ];
          specialArgs = {
            inherit env;
            inherit inputs;
          };
        };
      };
    };
}
