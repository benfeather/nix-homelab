{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "sonarr" = {
      hostname = "sonarr";
      image = "lscr.io/linuxserver/sonarr:latest";

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.sonarr.entrypoints" = "websecure";
        "traefik.http.routers.sonarr.rule" = "Host(`sonarr.${env.domain}`)";
        "traefik.http.services.sonarr.loadbalancer.server.port" = "8989";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.appdata_dir}/sonarr/config:/config"
        "${env.data_dir}:/data"
      ];
    };

    "sonarr-anime" = {
      hostname = "sonarr-anime";
      image = "lscr.io/linuxserver/sonarr:latest";

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.sonarr-anime.entrypoints" = "websecure";
        "traefik.http.routers.sonarr-anime.rule" = "Host(`sonarr-anime.${env.domain}`)";
        "traefik.http.services.sonarr-anime.loadbalancer.server.port" = "8989";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.appdata_dir}/sonarr-anime/config:/config"
        "${env.data_dir}:/data"
      ];
    };
  };
}
