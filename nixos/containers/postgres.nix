{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "postgres" = {
      image = "docker.io/library/postgres:alpine";
      hostname = "postgres";

      environment = {
        "POSTGRES_USER" = config.sops.placeholder."global/pg_user";
        "POSTGRES_PASSWORD" = config.sops.placeholder."global/pg_pass";
        "PUID" = env.puid;
        "PGID" = env.pgid;
        "TZ" = env.tz;
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.config_dir}/postgres:/var/lib/postgresql/data"
      ];
    };
  };
}
