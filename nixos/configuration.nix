{
  imports = [
    # Hardware
    ./hardware-configuration.nix

    # Base
    ./base/acme.nix
    ./base/boot.nix
    ./base/graphics.nix
    ./base/localization.nix
    ./base/networking.nix
    ./base/nix-core.nix
    ./base/programs.nix
    ./base/sops.nix
    ./base/system.nix
    ./base/users.nix
    ./base/virtualisation.nix

    # Scripts
    ./scripts/fix-permissions.nix
    ./scripts/oci-containers.nix

    # Services
    ./services/cron.nix
    ./services/docker-networks.nix
    ./services/openssh.nix
    ./services/qemu.nix
    ./services/restic.nix
    ./services/tailscale.nix
    ./services/vscode-server.nix
    ./services/xserver.nix

    # Networking containers
    ./containers/authelia.nix
    ./containers/traefik.nix

    # Homelab containers
    ./containers/audiobookshelf.nix
    ./containers/bazarr.nix
    ./containers/dockpeek.nix
    ./containers/dozzle.nix
    ./containers/fileflows.nix
    ./containers/flaresolver.nix
    ./containers/homepage.nix
    ./containers/immich.nix
    ./containers/kavita.nix
    ./containers/lidarr.nix
    ./containers/n8n.nix
    ./containers/profilarr.nix
    ./containers/prowlarr.nix
    ./containers/radarr.nix
    ./containers/readarr.nix
    # ./containers/romm.nix
    ./containers/sabnzbd.nix
    ./containers/seerr.nix
    ./containers/sonarr.nix
    ./containers/stash.nix
    ./containers/stirling-pdf.nix
    ./containers/uptime.nix
    ./containers/whisparr.nix
    ./containers/whoami.nix
    # ./containers/zerobyte.nix
  ];
}
