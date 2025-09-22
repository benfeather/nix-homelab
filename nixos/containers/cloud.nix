{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "cloud" = {
      hostname = "cloud";
      image = "docker.io/nextcloud:latest";

      dependsOn = [
        "cloud-db"
        "cloud-redis"
      ];

      environment = {
        "MYSQL_DATABASE" = "$DB_NAME";
        "MYSQL_HOST" = "cloud-db";
        "MYSQL_PASSWORD" = "$DB_PASS";
        "MYSQL_USER" = "$DB_USER";
        "NEXTCLOUD_TRUSTED_DOMAINS" = "cloud.${env.domain}";
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "REDIS_HOST" = "cloud-redis";
        "TZ" = env.tz;
      };

      environmentFiles = [
        config.sops.secrets."cloud".path
      ];

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.cloud.entrypoints" = "websecure";
        # "traefik.http.routers.cloud.middlewares" = "authelia@docker";
        "traefik.http.routers.cloud.rule" = "Host(`cloud.${env.domain}`)";
        "traefik.http.services.cloud.loadbalancer.server.port" = "80";
      };

      networks = [
        "backend"
        "proxy"
      ];

      volumes = [
        "${env.appdata_dir}/cloud/config:/config"
        "${env.data_dir}/cloud:/data"
      ];
    };

    "cloud-db" = {
      hostname = "cloud-db";
      image = "docker.io/mysql:latest";

      environment = {
        "MYSQL_DATABASE" = "$DB_NAME";
        "MYSQL_PASSWORD" = "$DB_PASS";
        "MYSQL_RANDOM_ROOT_PASSWORD" = "true";
        "MYSQL_USER" = "$DB_USER";
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      environmentFiles = [
        config.sops.secrets."cloud".path
      ];

      networks = [
        "backend"
      ];

      volumes = [
        "${env.appdata_dir}/cloud/db:/var/lib/mysql"
      ];
    };

    "cloud-redis" = {
      hostname = "cloud-redis";
      image = "docker.io/redis:latest";

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      networks = [
        "backend"
      ];

      volumes = [
        "${env.appdata_dir}/cloud/redis:/data"
      ];
    };
  };
}
