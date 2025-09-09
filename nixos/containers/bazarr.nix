{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers."bazarr" = {
    image = "lscr.io/linuxserver/bazarr:latest";
    hostname = "bazarr";

    environment = {
      "PUID" = env.puid;
      "PGID" = env.pgid;
      "TZ" = env.tz;
    };

    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.bazarr.rule" = "Host(`bazarr.${env.domain}`)";
      "traefik.http.routers.bazarr.entrypoints" = "websecure";
      "traefik.http.services.bazarr.loadbalancer.server.port" = "6767";
    };

    networks = [
      "proxy"
    ];

    ports = [
      "8002:6767"
    ];

    volumes = [
      "${env.config_dir}/bazarr/config:/config"
      "${env.data_dir}:/data"
    ];
  };
}
