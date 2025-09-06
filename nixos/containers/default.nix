{
  # imports = [
  #   ./containers/authentik.nix
  #   ./containers/bazarr-anime.nix
  #   ./containers/bazarr.nix
  #   ./containers/duplicati.nix
  #   ./containers/fileflows.nix
  #   ./containers/homepage.nix
  #   ./containers/huntarr.nix
  #   ./containers/jellyfin.nix
  #   ./containers/lidarr.nix
  #   ./containers/overseerr.nix
  #   ./containers/plex.nix
  #   ./containers/postgres.nix
  #   ./containers/prowlarr.nix
  #   ./containers/radarr-anime.nix
  #   ./containers/radarr.nix
  #   ./containers/recyclarr.nix
  #   ./containers/sabnzbd.nix
  #   ./containers/sonarr-anime.nix
  #   ./containers/sonarr.nix
  #   ./containers/tailscale.nix
  #   ./containers/traefik.nix
  #   ./containers/uptime-kuma.nix
  #   ./utils/network-init.nix
  # ];

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
