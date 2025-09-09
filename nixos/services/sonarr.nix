{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "sonarr" = {
      image = "lscr.io/linuxserver/sonarr:latest";
      hostname = "sonarr";

      environment = {
        "PUID" = env.puid;
        "PGID" = env.pgid;
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.sonarr.rule" = "Host(`sonarr.${env.domain}`)";
        "traefik.http.routers.sonarr.entrypoints" = "websecure";
        "traefik.http.services.sonarr.loadbalancer.server.port" = "8989";
      };

      networks = [
        "proxy"
      ];

      ports = [
        "8014:8989"
      ];

      volumes = [
        "${env.config_dir}/sonarr/config:/config"
        "${env.data_dir}:/data"
      ];
    };

    "sonarr-anime" = {
      image = "lscr.io/linuxserver/sonarr:latest";
      hostname = "sonarr-anime";

      environment = {
        "PUID" = env.puid;
        "PGID" = env.pgid;
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.sonarr-anime.rule" = "Host(`sonarr-anime.${env.domain}`)";
        "traefik.http.routers.sonarr-anime.entrypoints" = "websecure";
        "traefik.http.services.sonarr-anime.loadbalancer.server.port" = "8989";
      };

      networks = [
        "proxy"
      ];

      ports = [
        "8013:8989"
      ];

      volumes = [
        "${env.config_dir}/sonarr-anime/config:/config"
        "${env.data_dir}:/data"
      ];
    };
  };
}
