{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        80
        443
      ];
    };

    hostName = "hydra";
  };

  nix = {
    channel.enable = false;
    settings = {
      experimental-features = "nix-command flakes";
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  system.stateVersion = "25.05";

  time.timeZone = "Pacific/Auckland";

  users.users = {
    ben = {
      extraGroups = [
        "docker"
        "wheel"
      ];
      initialPassword = "changeme";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDRN844nMraLIO6ZSO5XlxVOd2va3pnnJMC/BRS41zIo"
      ];
    };
  };
}
