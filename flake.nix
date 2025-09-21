{
  description = "HomeLab NixOS Configuration";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    sops.url = "github:Mic92/sops-nix";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
  };

  outputs =
    {
      home-manager,
      nixpkgs,
      self,
      sops,
      vscode-server,
      ...
    }@inputs:
    let
      env = {
        backup_dir = "/mnt/unraid/backups";
        conf_dir = "/mnt/unraid/homelab/appdata";
        data_dir = "/mnt/unraid/homelab/data";
        domain = "benfeather.com";
        email = "contact@benfeather.dev";
        pgid = "131";
        puid = "1000";
        tz = "Pacific/Auckland";
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        modules = [
          home-manager.nixosModules.home-manager
          sops.nixosModules.sops
          vscode-server.nixosModules.default
          ./nixos/configuration.nix
        ];
        specialArgs = {
          inherit env;
          inherit inputs;
        };
      };
    };
}
