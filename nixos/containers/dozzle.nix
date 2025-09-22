{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "dozzle" = {
      hostname = "dozzle";
      image = "docker.io/amir20/dozzle:latest";

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.dozzle.entrypoints" = "websecure";
        "traefik.http.routers.dozzle.middlewares" = "authelia@docker";
        "traefik.http.routers.dozzle.rule" = "Host(`dozzle.${env.domain}`)";
        "traefik.http.services.dozzle.loadbalancer.server.port" = "8080";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock:ro"
      ];
    };
  };
}
