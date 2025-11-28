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
    ./scripts/backup-appdata.nix
    ./scripts/cleanup.nix
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
    ./containers/audiobookshelf.nix
    ./containers/bazarr.nix
    # ./containers/cloud.nix
    ./containers/dozzle.nix
    ./containers/fileflows.nix
    ./containers/flaresolver.nix
    ./containers/homepage.nix
    ./containers/huntarr.nix
    ./containers/jellyseerr.nix
    ./containers/kavita.nix
    ./containers/lidarr.nix
    ./containers/n8n.nix
    ./containers/notifiarr.nix
    ./containers/profilarr.nix
    ./containers/prowlarr.nix
    # ./containers/qbittorrent.nix
    ./containers/radarr.nix
    ./containers/readarr.nix
    # ./containers/romm.nix
    ./containers/sabnzbd.nix
    ./containers/sonarr.nix
    ./containers/stash.nix
    ./containers/stirling-pdf.nix
    ./containers/uptime.nix
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

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
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
        22 # SSH
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

      "cloudflare" = {
        format = "dotenv";
        sopsFile = ./secrets/cloudflare.env;
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

      "notifiarr" = {
        format = "dotenv";
        sopsFile = ./secrets/notifiarr.env;
        key = "";
      };

      "romm" = {
        format = "dotenv";
        sopsFile = ./secrets/romm.env;
        key = "";
      };

      "vpn" = {
        format = "dotenv";
        sopsFile = ./secrets/vpn.env;
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
        "video"
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

    daemon.settings.dns = [
      "1.1.1.1"
      "1.0.0.1"
    ];
  };

  virtualisation.oci-containers = {
    backend = "docker";
  };
}
