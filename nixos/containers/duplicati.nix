{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "duplicati" = {
      hostname = "duplicati";
      image = "lscr.io/linuxserver/duplicati:latest";

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
        "CLI_ARGS" = "";
        "DUPLICATI__WEBSERVICE_ALLOWED_HOSTNAMES" = "duplicati.${env.domain}";
      };

      environmentFiles = [
        config.sops.secrets."duplicati".path
      ];

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.duplicati.entrypoints" = "websecure";
        "traefik.http.routers.duplicati.rule" = "Host(`duplicati.${env.domain}`)";
        "traefik.http.services.duplicati.loadbalancer.server.port" = "8200";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.appdata_dir}/duplicati:/config"
        "${env.backup_dir}:/backups"
        "${env.data_dir}:/data"
      ];
    };
  };
}
