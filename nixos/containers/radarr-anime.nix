{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers."radarr-anime" = {
    image = "lscr.io/linuxserver/radarr:latest";
    hostname = "radarr-anime";

    environment = {
      "PUID" = env.puid;
      "PGID" = env.pgid;
      "TZ" = env.tz;
    };

    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.radarr-anime.rule" = "Host(`radarr-anime.${env.domain}`)";
      "traefik.http.routers.radarr-anime.entrypoints" = "websecure";
      "traefik.http.services.radarr-anime.loadbalancer.server.port" = "7878";
    };

    networks = [
      "proxy"
    ];

    ports = [
      "8010:7878"
    ];

    volumes = [
      "${env.config_dir}/radarr-anime/config:/config"
      "${env.data_dir}:/data"
    ];
  };
}
