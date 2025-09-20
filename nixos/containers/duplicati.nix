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
        "DUPLICATI__WEBSERVICE_ALLOWED_HOSTNAMES" = "duplicati.${env.domain}";
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      environmentFiles = [
        config.sops.secrets."duplicati".path
      ];

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.duplicati.entrypoints" = "websecure";
        "traefik.http.routers.duplicati.middlewares" = "authelia@docker";
        "traefik.http.routers.duplicati.rule" = "Host(`duplicati.${env.domain}`)";
        "traefik.http.services.duplicati.loadbalancer.server.port" = "8200";
      };

      volumes = [
        "${env.backup_dir}:/backups"
        "${env.conf_dir}/duplicati/config:/config"
        "${env.conf_dir}:/source"
      ];
    };
  };
}
