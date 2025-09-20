{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "radarr" = {
      hostname = "radarr";
      image = "lscr.io/linuxserver/radarr:latest";

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.radarr.entrypoints" = "websecure";
        "traefik.http.routers.radarr.middlewares" = "authelia@docker";
        "traefik.http.routers.radarr.rule" = "Host(`radarr.home`) || Host(`radarr.${env.domain}`)";
        "traefik.http.services.radarr.loadbalancer.server.port" = "7878";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.conf_dir}/radarr/config:/config"
        "${env.data_dir}:/data"
      ];
    };

    "radarr-anime" = {
      hostname = "radarr-anime";
      image = "lscr.io/linuxserver/radarr:latest";

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.radarr-anime.entrypoints" = "websecure";
        "traefik.http.routers.radarr-anime.middlewares" = "authelia@docker";
        "traefik.http.routers.radarr-anime.rule" =
          "Host(`radarr-anime.home`) || Host(`radarr-anime.${env.domain}`)";
        "traefik.http.services.radarr-anime.loadbalancer.server.port" = "7878";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.conf_dir}/radarr-anime/config:/config"
        "${env.data_dir}:/data"
      ];
    };
  };
}
