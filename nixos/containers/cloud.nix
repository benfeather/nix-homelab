{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "cloud" = {
      hostname = "cloud";
      image = "lscr.io/linuxserver/nextcloud:latest";

      dependsOn = [
        "cloud-db"
        "cloud-redis"
      ];

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
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
        "traefik.http.services.cloud.loadbalancer.server.port" = "443";
      };

      networks = [
        "backend"
        "proxy"
      ];

      volumes = [
        "${env.conf_dir}/cloud/config:/config"
        "${env.data_dir}:/data"
      ];
    };

    "cloud-db" = {
      hostname = "cloud-db";
      image = "lscr.io/linuxserver/mariadb:latest";

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
        config.sops.secrets."cloud".path
      ];

      networks = [
        "backend"
      ];

      volumes = [
        "${env.conf_dir}/cloud/db:/config"
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
        "${env.conf_dir}/cloud/redis:/data"
      ];
    };
  };
}
