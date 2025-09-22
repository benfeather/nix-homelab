{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "jellyseerr" = {
      hostname = "jellyseerr";
      image = "docker.io/fallenbagel/jellyseerr:latest";

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.jellyseerr.entrypoints" = "websecure";
        # "traefik.http.routers.jellyseerr.middlewares" = "authelia@docker";
        "traefik.http.routers.jellyseerr.rule" = "Host(`jellyseerr.${env.domain}`)";
        "traefik.http.services.jellyseerr.loadbalancer.server.port" = "5055";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.appdata_dir}/jellyseerr/config:/config"
      ];
    };
  };
}
