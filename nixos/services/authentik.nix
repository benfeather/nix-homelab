{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "authentik-server" = {
      image = "ghcr.io/goauthentik/server:latest";
      hostname = "authentik-server";
      cmd = [ "server" ];

      environment = {
        "AUTHENTIK_SECRET_KEY" = "secret";
        "AUTHENTIK_REDIS__HOST" = "authentik-redis";
        "AUTHENTIK_POSTGRESQL__HOST" = "authentik-postgresql";
        "AUTHENTIK_POSTGRESQL__NAME" = "authentik";
        "AUTHENTIK_POSTGRESQL__USER" = config.sops.placeholder."global/pg_user";
        "AUTHENTIK_POSTGRESQL__PASSWORD" = config.sops.placeholder."global/pg_pass";
        "TZ" = env.tz;
      };

      ports = [
        "9000:9000"
        "9443:9443"
      ];

      volumes = [
        "${env.config_dir}/authentik/media:/media"
        "${env.config_dir}/authentik/custom-templates:/templates"
      ];
    };

    "authentik-worker" = {
      image = "ghcr.io/goauthentik/server:latest";
      hostname = "authentik-worker";
      cmd = [ "worker" ];

      environment = {
        "AUTHENTIK_SECRET_KEY" = "changeme";
        "AUTHENTIK_REDIS__HOST" = "authentik-redis";
        "AUTHENTIK_POSTGRESQL__HOST" = "authentik-postgres";
        "AUTHENTIK_POSTGRESQL__NAME" = "authentik";
        "AUTHENTIK_POSTGRESQL__USER" = config.sops.placeholder."global/pg_user";
        "AUTHENTIK_POSTGRESQL__PASSWORD" = config.sops.placeholder."global/pg_pass";
        "TZ" = env.tz;
      };

      volumes = [
        "${env.config_dir}/authentik/media:/media"
        "${env.config_dir}/authentik/certs:/certs"
        "${env.config_dir}/authentik/custom-templates:/templates"
        "/var/run/docker.sock:/var/run/docker.sock"
      ];
    };

    "authentik-redis" = {
      image = "docker.io/library/redis:alpine";
      hostname = "authentik-redis";

      environment = {
        "TZ" = env.tz;
      };

      volumes = [
        "${env.config_dir}/authentik/redis:/data"
      ];
    };

    "authentik-postgres" = {
      image = "docker.io/library/postgres:alpine";
      hostname = "postgres";

      environment = {
        "POSTGRES_USER" = config.sops.placeholder."global/pg_user";
        "POSTGRES_PASSWORD" = config.sops.placeholder."global/pg_pass";
        "PUID" = env.puid;
        "PGID" = env.pgid;
        "TZ" = env.tz;
      };

      volumes = [
        "${env.config_dir}/authentik/db:/var/lib/postgresql/data"
      ];
    };
  };
}
