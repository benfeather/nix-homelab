{
  description = "HomeLab NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
  };

  outputs =
    {
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
            vscode-server.nixosModules.default
            ./nixos/configuration.nix
          ];
          specialArgs = {
            inherit env;
            inherit inputs;
            inherit outputs;
          };
        };
      };
    };
}
