{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "overseerr" = {
      hostname = "overseerr";
      image = "lscr.io/linuxserver/overseerr:latest";

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.overseerr.entrypoints" = "websecure";
        "traefik.http.routers.overseerr.middlewares" = "authelia@docker";
        "traefik.http.routers.overseerr.rule" = "Host(`overseerr.${env.domain}`)";
        "traefik.http.services.overseerr.loadbalancer.server.port" = "5055";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.conf_dir}/overseerr/config:/config"
      ];
    };
  };
}
