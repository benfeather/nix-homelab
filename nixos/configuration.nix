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

    # Nix Scripts
    ./scripts/archive.nix
    ./scripts/archive-cleanup.nix
    ./scripts/backup-appdata.nix
    ./scripts/fix-permissions.nix
    ./scripts/nix-rebuild.nix
    ./scripts/nix-update.nix
    ./scripts/oci-containers.nix
    ./scripts/rclone-sync.nix

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

    # Homelab
    # ./containers/audiobookshelf.nix
    # ./containers/bazarr.nix
    # ./containers/bookshelf.nix
    # ./containers/cloud.nix
    # ./containers/fileflows.nix
    ./containers/homepage.nix
    # ./containers/huntarr.nix
    # ./containers/jellyfin.nix
    # ./containers/jellyseerr.nix
    ./containers/lidarr.nix
    # ./containers/n8n.nix
    # ./containers/overseerr.nix
    # ./containers/plex.nix
    ./containers/prowlarr.nix
    ./containers/qbittorrent.nix
    ./containers/radarr.nix
    # ./containers/recyclarr.nix
    # ./containers/romm.nix
    ./containers/sabnzbd.nix
    ./containers/sonarr.nix
    ./containers/stash.nix
    # ./containers/uptime-kuma.nix
    ./containers/watchtower.nix
    ./containers/whisparr.nix
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
    rclone
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
      options = "--delete-older-than 7d";
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

      "cloud" = {
        format = "dotenv";
        sopsFile = ./secrets/cloud.env;
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

      "gcs" = {
        format = "json";
        sopsFile = ./secrets/gcs.json;
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

    rootless = {
      enable = true;
      setSocketVariable = true;

      daemon.settings.dns = [
        "1.1.1.1"
        "1.0.0.1"
      ];
    };
  };

  virtualisation.oci-containers = {
    backend = "docker";
  };
}
