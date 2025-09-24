{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "readarr" = {
      hostname = "readarr";
      image = "ghcr.io/pennydreadful/bookshelf:hardcover";

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.readarr.entrypoints" = "websecure";
        "traefik.http.routers.readarr.rule" = "Host(`readarr.${env.domain}`)";
        "traefik.http.services.readarr.loadbalancer.server.port" = "8787";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.appdata_dir}/readarr/config:/config"
        "${env.data_dir}:/data"
      ];
    };
  };
}
