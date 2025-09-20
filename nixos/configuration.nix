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

    # Nix Services
    ./services/cron.nix
    ./services/docker-networks.nix
    ./services/openssh.nix
    ./services/vscode-server.nix
    ./services/xserver.nix

    # Networking
    ./containers/authelia.nix
    ./containers/cf-tunnel.nix
    ./containers/traefik.nix
    ./containers/whoami.nix

    # Homelab
    ./containers/bazarr.nix
    ./containers/bookshelf.nix
    ./containers/duplicati.nix
    ./containers/fileflows.nix
    ./containers/homepage.nix
    ./containers/huntarr.nix
    ./containers/jellyfin.nix
    ./containers/lidarr.nix
    ./containers/overseerr.nix
    ./containers/plex.nix
    ./containers/prowlarr.nix
    ./containers/radarr.nix
    ./containers/recyclarr.nix
    ./containers/sabnzbd.nix
    ./containers/sonarr.nix
    ./containers/stash.nix
    ./containers/uptime-kuma.nix
    ./containers/watchtower.nix
    ./containers/whisparr.nix
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

  fileSystems."/mnt/unraid" = {
    device = "unraid";
    fsType = "9p";
    options = [
      "auto"
      "exec" # Permit execution of binaries and other executable files
      "nofail" # Prevent system from failing if this drive doesn't mount
      "rw"
      "users" # Allows any user to mount and unmount
    ];
  };

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

      "duplicati" = {
        format = "dotenv";
        sopsFile = ./secrets/duplicati.env;
        key = "";
      };

      "homepage" = {
        format = "dotenv";
        sopsFile = ./secrets/homepage.env;
        key = "";
      };

      "plex" = {
        format = "dotenv";
        sopsFile = ./secrets/plex.env;
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
