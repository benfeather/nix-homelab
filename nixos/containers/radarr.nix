{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "radarr" = {
      image = "lscr.io/linuxserver/radarr:latest";
      hostname = "radarr";

      environment = {
        "PUID" = env.puid;
        "PGID" = env.pgid;
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.radarr.entrypoints" = "websecure";
        "traefik.http.routers.radarr.middlewares" = "authelia@docker";
        "traefik.http.routers.radarr.rule" = "Host(`radarr.${env.domain}`)";
        "traefik.http.services.radarr.loadbalancer.server.port" = "7878";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.conf_dir}/radarr:/config"
        "${env.data_dir}:/data"
      ];
    };

    "radarr-anime" = {
      image = "lscr.io/linuxserver/radarr:latest";
      hostname = "radarr-anime";

      environment = {
        "PUID" = env.puid;
        "PGID" = env.pgid;
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.radarr-anime.entrypoints" = "websecure";
        "traefik.http.routers.radarr-anime.middlewares" = "authelia@docker";
        "traefik.http.routers.radarr-anime.rule" = "Host(`radarr-anime.${env.domain}`)";
        "traefik.http.services.radarr-anime.loadbalancer.server.port" = "7878";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.conf_dir}/radarr-anime:/config"
        "${env.data_dir}:/data"
      ];
    };
  };
}
