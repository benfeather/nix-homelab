{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "audiobookshelf" = {
      hostname = "audiobookshelf";
      image = "ghcr.io/advplyr/audiobookshelf:latest";

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.audiobookshelf.entrypoints" = "websecure";
        "traefik.http.routers.audiobookshelf.middlewares" = "authelia@docker";
        "traefik.http.routers.audiobookshelf.rule" = "Host(`audiobookshelf.${env.domain}`)";
        "traefik.http.services.audiobookshelf.loadbalancer.server.port" = "80";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.appdata_dir}/audiobookshelf/config:/config"
        "${env.appdata_dir}/audiobookshelf/metadata:/metadata"
        "${env.data_dir}:/data"
      ];
    };
  };
}
