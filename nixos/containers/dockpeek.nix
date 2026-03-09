{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "dockpeek" = {
      hostname = "dockpeek";
      image = "docker.io/dockpeek/dockpeek:latest";

      environment = {
        "DISABLE_AUTH" = "true";
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.dockpeek.entrypoints" = "websecure";
        "traefik.http.routers.dockpeek.middlewares" = "authelia@docker";
        "traefik.http.routers.dockpeek.rule" = "Host(`dockpeek.${env.domain}`)";
        "traefik.http.services.dockpeek.loadbalancer.server.port" = "8000";
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
