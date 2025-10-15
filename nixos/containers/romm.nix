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
        "DB_NAME" = "db";
        "DB_USER" = "db";
      };

      environmentFiles = [
        config.sops.secrets."romm".path
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
        "romm-redis:/redis-data"
        "romm-resources:/romm/resources"
        "${env.appdata_dir}/romm/assets:/romm/assets"
        "${env.appdata_dir}/romm/config:/romm/config"
        "${env.data_dir}/media/games:/romm/library"
      ];
    };

    "romm-db" = {
      hostname = "romm-db";
      image = "docker.io/mariadb:latest";

      environment = {
        "MARIADB_DATABASE" = "db";
        "MARIADB_USER" = "db";
      };

      environmentFiles = [
        config.sops.secrets."romm".path
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
