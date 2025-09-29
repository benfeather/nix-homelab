{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "kavita" = {
      hostname = "kavita";
      image = "lscr.io/linuxserver/kavita:latest";

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.kavita.entrypoints" = "websecure";
        "traefik.http.routers.kavita.rule" = "Host(`kavita.${env.domain}`)";
        "traefik.http.services.kavita.loadbalancer.server.port" = "5000";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.appdata_dir}/kavita/config:/config"
        "${env.data_dir}:/data"
      ];
    };
  };
}
