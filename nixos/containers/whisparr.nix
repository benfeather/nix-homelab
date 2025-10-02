{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "whisparr" = {
      hostname = "whisparr";
      image = "ghcr.io/hotio/whisparr:v3";

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.whisparr.entrypoints" = "websecure";
        "traefik.http.routers.whisparr.rule" = "Host(`whisparr.${env.domain}`)";
        "traefik.http.services.whisparr.loadbalancer.server.port" = "6969";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.appdata_dir}/whisparr:/config"
        "${env.data_dir}:/data"
      ];
    };
  };
}
