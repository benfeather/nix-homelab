{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "stash" = {
      hostname = "stash";
      image = "docker.io/stashapp/stash:latest";

      environment = {
        "STASH_CACHE" = "/cache";
        "STASH_GENERATED" = "/generated";
        "STASH_METADATA" = "/metadata";
        "STASH_PORT" = "6969";
        "STASH_STASH" = "/data";
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.stash.entrypoints" = "websecure";
        "traefik.http.routers.stash.middlewares" = "authelia@docker";
        "traefik.http.routers.stash.rule" = "Host(`stash.${env.domain}`)";
        "traefik.http.services.stash.loadbalancer.server.port" = "6969";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.appdata_dir}/stash/blobs:/blobs"
        "${env.appdata_dir}/stash/cache:/cache"
        "${env.appdata_dir}/stash/config:/root/.stash"
        "${env.appdata_dir}/stash/generated:/generated"
        "${env.appdata_dir}/stash/metadata:/metadata"
        "${env.data_dir}:/data"
      ];
    };
  };
}
