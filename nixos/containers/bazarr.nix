{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "bazarr" = {
      hostname = "bazarr";
      image = "lscr.io/linuxserver/bazarr:latest";

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.bazarr.entrypoints" = "websecure";
        "traefik.http.routers.bazarr.rule" = "Host(`bazarr.${env.domain}`)";
        "traefik.http.services.bazarr.loadbalancer.server.port" = "6767";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.appdata_dir}/bazarr:/config"
        "${env.data_dir}:/data"
      ];
    };

    "bazarr-anime" = {
      hostname = "bazarr-anime";
      image = "lscr.io/linuxserver/bazarr:latest";

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.bazarr-anime.entrypoints" = "websecure";
        "traefik.http.routers.bazarr-anime.rule" = "Host(`bazarr-anime.${env.domain}`)";
        "traefik.http.services.bazarr-anime.loadbalancer.server.port" = "6767";
      };

      volumes = [
        "${env.appdata_dir}/bazarr-anime:/config"
        "${env.data_dir}:/data"
      ];
    };
  };
}
