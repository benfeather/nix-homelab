{
  pkgs,
  ...
}:
{
  systemd.services.network-init = {
    serviceConfig.Type = "oneshot";

    wantedBy = [
      "docker-bazarr-anime.service"
      "docker-bazarr.service"
      "docker-huntarr.service"
      "docker-jellyfin.service"
      "docker-lidarr.service"
      "docker-overseerr.service"
      "docker-plex.service"
      "docker-prowlarr.service"
      "docker-radarr-anime.service"
      "docker-radarr.service"
      "docker-sabnzbd.service"
      "docker-sonarr-anime.service"
      "docker-sonarr.service"
      "docker-traefik.service"
      "docker-uptime.service"
    ];

    # Docker Network Initialization Script
    script = ''
      ${pkgs.docker}/bin/docker network inspect proxy || \
      ${pkgs.docker}/bin/docker network create --driver="bridge" proxy

      ${pkgs.docker}/bin/docker network inspect host || \
      ${pkgs.docker}/bin/docker network create --driver="host" host
    '';
  };
}
