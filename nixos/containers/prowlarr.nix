{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "prowlarr" = {
      hostname = "prowlarr";
      image = "lscr.io/linuxserver/prowlarr:latest";

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.prowlarr.entrypoints" = "websecure";
        "traefik.http.routers.prowlarr.rule" = "Host(`prowlarr.${env.domain}`)";
        "traefik.http.services.prowlarr.loadbalancer.server.port" = "9696";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.appdata_dir}/prowlarr:/config"
        "${env.data_dir}:/data"
      ];
    };
  };
}
