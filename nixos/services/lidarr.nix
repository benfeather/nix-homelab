{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers."lidarr" = {
    image = "lscr.io/linuxserver/lidarr:latest";
    hostname = "lidarr";

    environment = {
      "PUID" = env.puid;
      "PGID" = env.pgid;
      "TZ" = env.tz;
    };

    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.lidarr.rule" = "Host(`lidarr.${env.domain}`)";
      "traefik.http.routers.lidarr.entrypoints" = "websecure";
      "traefik.http.services.lidarr.loadbalancer.server.port" = "7878";
    };

    networks = [
      "proxy"
    ];

    ports = [
      "8006:7878"
    ];

    volumes = [
      "${env.conf_dir}/lidarr/config:/config"
      "${env.data_dir}:/data"
    ];
  };
}
