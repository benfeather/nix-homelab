{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "homepage" = {
      hostname = "homepage";
      image = "ghcr.io/gethomepage/homepage:latest";

      environment = {
        "HOMEPAGE_ALLOWED_HOSTS" = "home.${env.domain}";
        "HOMEPAGE_VAR_DOMAIN" = "${env.domain}";
        "HOMEPAGE_VAR_LIDARR_API_KEY" = "$LIDARR_API_KEY";
        "HOMEPAGE_VAR_PROWLARR_API_KEY" = "$PROWLARR_API_KEY";
        "HOMEPAGE_VAR_QBITTORRENT_PASS" = "$QBITTORRENT_PASS";
        "HOMEPAGE_VAR_RADARR_API_KEY" = "$RADARR_API_KEY";
        "HOMEPAGE_VAR_RADARR_ANIME_API_KEY" = "$RADARR_ANIME_API_KEY";
        "HOMEPAGE_VAR_READARR_API_KEY" = "$READARR_API_KEY";
        "HOMEPAGE_VAR_READARR_AUDIO_API_KEY" = "$READARR_AUDIO_API_KEY";
        "HOMEPAGE_VAR_SABNZBD_API_KEY" = "$SABNZBD_API_KEY";
        "HOMEPAGE_VAR_SONARR_API_KEY" = "$SONARR_API_KEY";
        "HOMEPAGE_VAR_SONARR_ANIME_API_KEY" = "$SONARR_ANIME_API_KEY";
        "HOMEPAGE_VAR_WHISPARR_API_KEY" = "$WHISPARR_API_KEY";
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      environmentFiles = [
        config.sops.secrets."global".path
      ];

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.homepage.entrypoints" = "websecure";
        "traefik.http.routers.homepage.middlewares" = "authelia@docker";
        "traefik.http.routers.homepage.rule" = "Host(`home.${env.domain}`)";
        "traefik.http.services.homepage.loadbalancer.server.port" = "3000";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock:ro"
        "${env.appdata_dir}/homepage:/app/config"
      ];
    };
  };
}
