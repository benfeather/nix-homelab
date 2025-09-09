{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers."radarr" = {
    image = "lscr.io/linuxserver/radarr:latest";
    hostname = "radarr";

    environment = {
      "PUID" = env.puid;
      "PGID" = env.pgid;
      "TZ" = env.tz;
    };

    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.radarr.rule" = "Host(`radarr.${env.domain}`)";
      "traefik.http.routers.radarr.entrypoints" = "websecure";
      "traefik.http.services.radarr.loadbalancer.server.port" = "7878";
    };

    networks = [
      "proxy"
    ];

    ports = [
      "8011:7878"
    ];

    volumes = [
      "${env.config_dir}/radarr/config:/config"
      "${env.data_dir}:/data"
    ];
  };
}
