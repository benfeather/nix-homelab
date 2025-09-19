{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "lidarr" = {
      hostname = "lidarr";
      image = "lscr.io/linuxserver/lidarr:latest";

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.lidarr.entrypoints" = "websecure";
        "traefik.http.routers.lidarr.middlewares" = "authelia@docker";
        "traefik.http.routers.lidarr.rule" = "Host(`lidarr.${env.domain}`)";
        "traefik.http.services.lidarr.loadbalancer.server.port" = "8686";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.conf_dir}/lidarr/config:/config"
        "${env.data_dir}:/data"
      ];
    };
  };
}
