{
  config,
  env,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix

    ./services/cron.nix
    ./services/docker-networks.nix
    ./services/openssh.nix
    ./services/vscode-server.nix
    ./services/xserver.nix

    ./containers/authelia.nix
    ./containers/cf-tunnel.nix
    ./containers/radarr.nix
    ./containers/traefik.nix
    ./containers/whoami.nix
  ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  environment.systemPackages = with pkgs; [
    curl
    git
    home-manager
    nano
    nixfmt-rfc-style
    sops
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.nixos = {
      home.stateVersion = "25.05";

      programs.git = {
        enable = true;
        extraConfig = {
          user.name = "Ben Feather";
          user.email = "contact@benfeather.dev";
          init.defaultBranch = "master";
        };
      };
    };
  };

  i18n = {
    defaultLocale = "en_NZ.UTF-8";

    extraLocaleSettings = {
      LC_ADDRESS = "en_NZ.UTF-8";
      LC_IDENTIFICATION = "en_NZ.UTF-8";
      LC_MEASUREMENT = "en_NZ.UTF-8";
      LC_MONETARY = "en_NZ.UTF-8";
      LC_NAME = "en_NZ.UTF-8";
      LC_NUMERIC = "en_NZ.UTF-8";
      LC_PAPER = "en_NZ.UTF-8";
      LC_TELEPHONE = "en_NZ.UTF-8";
      LC_TIME = "en_NZ.UTF-8";
    };
  };

  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        80
        443
      ];
    };

    hostName = "nixos";

    networkmanager.enable = true;
  };

  nix = {
    channel.enable = false;

    settings = {
      experimental-features = "nix-command flakes";
    };

    gc = {
      automatic = true;
      dates = "03:00";
      options = "--delete-older-than 3d";
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  sops = {
    age.keyFile = "/home/nixos/.config/sops/age/keys.txt";

    secrets = {
      "authelia" = {
        format = "dotenv";
        sopsFile = ./secrets/authelia.env;
        key = "";
      };

      "cloudflare" = {
        format = "dotenv";
        sopsFile = ./secrets/cloudflare.env;
        key = "";
      };
    };
  };

  system.stateVersion = "25.05";

  time.timeZone = env.tz;

  users = {
    users.nixos = {
      extraGroups = [
        "docker"
        "networkmanager"
        "wheel"
      ];

      isNormalUser = true;

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDRN844nMraLIO6ZSO5XlxVOd2va3pnnJMC/BRS41zIo"
      ];
    };
  };

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  virtualisation.oci-containers = {
    backend = "docker";
  };
}
