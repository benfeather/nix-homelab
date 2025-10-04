{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "romm" = {
      hostname = "romm";
      image = "docker.io/rommapp/romm:latest";

      dependsOn = [
        "romm-db"
      ];

      environment = {
        "DB_HOST" = "romm-db";
        "DB_NAME" = "$DB_NAME";
        "DB_USER" = "$DB_USER";
        "DB_PASSWD" = "$DB_PASS";
        "ROMM_AUTH_SECRET_KEY" = "$ROMM_AUTH_SECRET_KEY";
        "SCREENSCRAPER_USER" = "$SCREENSCRAPER_USER";
        "SCREENSCRAPER_PASSWORD" = "$SCREENSCRAPER_PASS";
        "RETROACHIEVEMENTS_API_KEY" = "$RETROACHIEVEMENTS_API_KEY";
        "STEAMGRIDDB_API_KEY" = "$STEAMGRIDDB_API_KEY";
        "HASHEOUS_API_ENABLED" = "true";
      };

      environmentFiles = [
        config.sops.secrets."global".path
      ];

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.romm.entrypoints" = "websecure";
        "traefik.http.routers.romm.rule" = "Host(`romm.${env.domain}`)";
        "traefik.http.services.romm.loadbalancer.server.port" = "8080";
      };

      networks = [
        "backend"
        "proxy"
      ];

      volumes = [
        "${env.appdata_dir}/romm/assets:/romm/assets"
        "${env.appdata_dir}/romm/config:/romm/config"
        "${env.appdata_dir}/romm/redis:/redis-data"
        "${env.appdata_dir}/romm/resources:/romm/resources"
        "${env.data_dir}/games:/data"
      ];
    };

    "romm-db" = {
      hostname = "romm-db";
      image = "docker.io/mariadb:latest";

      environment = {
        "MARIADB_ROOT_PASSWORD" = "$DB_ROOT_PASS";
        "MARIADB_DATABASE" = "$DB_NAME";
        "MARIADB_USER" = "$DB_USER";
        "MARIADB_PASSWORD" = "$DB_PASS";
      };

      environmentFiles = [
        config.sops.secrets."global".path
      ];

      volumes = [
        "${env.appdata_dir}/romm/db:/var/lib/mysql"
      ];

      networks = [
        "backend"
      ];
    };
  };
}
