{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "owncloud" = {
      hostname = "owncloud";
      image = "docker.io/owncloud/server:latest";

      dependsOn = [
        "owncloud-db"
        "owncloud-redis"
      ];

      environment = {
        "OWNCLOUD_DOMAIN" = "cloud.${env.domain}";
        "OWNCLOUD_TRUSTED_DOMAINS" = "cloud.${env.domain}";
        "OWNCLOUD_DB_TYPE" = "mysql";
        "OWNCLOUD_DB_NAME" = "$DB_NAME";
        "OWNCLOUD_DB_USERNAME" = "$DB_USER";
        "OWNCLOUD_DB_PASSWORD" = "$DB_PASS";
        "OWNCLOUD_DB_HOST" = "owncloud-db";
        "OWNCLOUD_ADMIN_USERNAME" = "$ADMIN_USER";
        "OWNCLOUD_ADMIN_PASSWORD" = "$ADMIN_PASS";
        "OWNCLOUD_MYSQL_UTF8MB4" = "true";
        "OWNCLOUD_REDIS_ENABLED" = "true";
        "OWNCLOUD_REDIS_HOST" = "owncloud-redis";
        "OWNCLOUD_REDIS_PASSWORD" = "$REDIS_PASS";
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      environmentFiles = [
        config.sops.secrets."owncloud".path
      ];

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.owncloud.entrypoints" = "websecure";
        # "traefik.http.routers.owncloud.middlewares" = "authelia@docker";
        "traefik.http.routers.owncloud.rule" = "Host(`cloud.${env.domain}`)";
        "traefik.http.services.owncloud.loadbalancer.server.port" = "8080";
      };

      networks = [
        "backend"
        "proxy"
      ];

      volumes = [
        "${env.data_dir}:/mnt/data"
      ];
    };

    "owncloud-db" = {
      hostname = "owncloud-db";
      image = "lscr.io/linuxserver/mariadb:latest";

      cmd = [
        "--innodb-log-file-size=64M"
        "--max-allowed-packet=128M"
      ];

      environment = {
        "MYSQL_DATABASE" = "$DB_NAME";
        "MYSQL_PASSWORD" = "$DB_PASS";
        "MYSQL_ROOT_PASSWORD" = "$DB_PASS";
        "MYSQL_USER" = "$DB_USER";
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      environmentFiles = [
        config.sops.secrets."owncloud".path
      ];

      networks = [
        "backend"
      ];

      volumes = [
        "${env.conf_dir}/owncloud/db:/config"
      ];
    };

    "owncloud-redis" = {
      hostname = "owncloud-redis";
      image = "docker.io/redis:latest";

      cmd = [
        "--databases=1"
        "--requirepass=$REDIS_PASS"
      ];

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      environmentFiles = [
        config.sops.secrets."owncloud".path
      ];

      networks = [
        "backend"
      ];

      volumes = [
        "${env.conf_dir}/owncloud/redis:/data"
      ];
    };
  };
}
