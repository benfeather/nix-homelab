{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "uptime" = {
      hostname = "uptime";
      image = "docker.io/louislam/uptime-kuma:alpine";

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.uptime.entrypoints" = "websecure";
        "traefik.http.routers.uptime.middlewares" = "authelia@docker";
        "traefik.http.routers.uptime.rule" = "Host(`uptime.${env.domain}`)";
        "traefik.http.services.uptime.loadbalancer.server.port" = "3001";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.appdata_dir}/uptime/config:/app/data"
      ];
    };
  };
}
