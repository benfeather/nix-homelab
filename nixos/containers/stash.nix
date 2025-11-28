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
        "STASH_CACHE" = "/stash/cache";
        "STASH_GENERATED" = "/stash/generated";
        "STASH_METADATA" = "/stash/metadata";
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
        "/appdata/stash/blobs:/stash/blobs"
        "/appdata/stash/cache:/stash/cache"
        "/appdata/stash/config:/root/.stash"
        "/appdata/stash/generated:/stash/generated"
        "/appdata/stash/metadata:/stash/metadata"
        "${env.data_dir}:/data"
      ];
    };
  };
}
