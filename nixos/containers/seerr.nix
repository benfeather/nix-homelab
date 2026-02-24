{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "seerr" = {
      hostname = "seerr";
      image = "ghcr.io/seerr-team/seerr:latest";

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.seerr.entrypoints" = "websecure";
        # "traefik.http.routers.seerr.middlewares" = "authelia@docker";
        "traefik.http.routers.seerr.rule" = "Host(`seerr.${env.domain}`)";
        "traefik.http.services.seerr.loadbalancer.server.port" = "5055";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.appdata_dir}/seerr:/app/config"
      ];
    };
  };
}
