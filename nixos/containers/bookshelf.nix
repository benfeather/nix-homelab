{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "bookshelf" = {
      hostname = "bookshelf";
      image = "ghcr.io/pennydreadful/bookshelf:hardcover";

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.bookshelf.entrypoints" = "websecure";
        "traefik.http.routers.bookshelf.middlewares" = "authelia@docker";
        "traefik.http.routers.bookshelf.rule" = "Host(`bookshelf.${env.domain}`)";
        "traefik.http.services.bookshelf.loadbalancer.server.port" = "8787";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.appdata_dir}/bookshelf/config:/config"
        "${env.data_dir}:/data"
      ];
    };
  };
}
