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
        "${env.appdata_dir}/readarr:/config"
        "${env.data_dir}:/data"
      ];
    };

    "readarr-audio" = {
      hostname = "readarr-audio";
      image = "ghcr.io/pennydreadful/bookshelf:hardcover";

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.readarr-audio.entrypoints" = "websecure";
        "traefik.http.routers.readarr-audio.rule" = "Host(`readarr-audio.${env.domain}`)";
        "traefik.http.services.readarr-audio.loadbalancer.server.port" = "8787";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.appdata_dir}/readarr-audio:/config"
        "${env.data_dir}:/data"
      ];
    };
  };
}
