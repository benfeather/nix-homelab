{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "huntarr" = {
      hostname = "huntarr";
      image = "ghcr.io/plexguide/huntarr:latest";

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.huntarr.entrypoints" = "websecure";
        "traefik.http.routers.huntarr.rule" = "Host(`huntarr.${env.domain}`)";
        "traefik.http.services.huntarr.loadbalancer.server.port" = "9705";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.appdata_dir}/huntarr:/config"
      ];
    };
  };
}
