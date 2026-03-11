{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "immich-server" = {
      hostname = "immich-server";
      image = "ghcr.io/immich-app/immich-server:v2";

      dependsOn = [
        "immich-db"
        "immich-machine-learning"
        "immich-redis"
      ];

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      environmentFiles = [
        config.sops.secrets."immich".path
      ];

      labels = {
        "traefik.enable" = "true";
        "traefik.docker.network" = "proxy";
        "traefik.http.routers.immich-server.entrypoints" = "websecure";
        "traefik.http.routers.immich-server.rule" = "Host(`immich.${env.domain}`)";
        "traefik.http.services.immich-server.loadbalancer.server.port" = "2283";
      };

      networks = [
        "backend"
        "proxy"
      ];

      volumes = [
        "${env.appdata_dir}/immich:/config"
        "${env.data_dir}/media/library:/data"
      ];
    };

    "immich-machine-learning" = {
      hostname = "immich-machine-learning";
      image = "ghcr.io/immich-app/immich-machine-learning:v2";

      dependsOn = [
        "immich-db"
        "immich-redis"
      ];

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      environmentFiles = [
        config.sops.secrets."immich".path
      ];

      networks = [
        "backend"
      ];

      volumes = [
        "immich-ml-cache:/cache"
      ];
    };

    "immich-redis" = {
      hostname = "immich-redis";
      image = "docker.io/redis:8";

      networks = [
        "backend"
      ];
    };

    "immich-db" = {
      hostname = "immich-db";
      image = "ghcr.io/immich-app/postgres:15-vectorchord0.5.3";

      environment = {
        "POSTGRES_INITDB_ARGS" = "--data-checksums";
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      environmentFiles = [
        config.sops.secrets."immich".path
      ];

      networks = [
        "backend"
      ];

      volumes = [
        "${env.appdata_dir}/immich/db:/var/lib/postgresql/data"
      ];
    };
  };
}
