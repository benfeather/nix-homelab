{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers."bazarr-anime" = {
    image = "lscr.io/linuxserver/bazarr:latest";
    hostname = "bazarr-anime";

    environment = {
      "PUID" = env.puid;
      "PGID" = env.pgid;
      "TZ" = env.tz;
    };

    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.bazarr-anime.rule" = "Host(`bazarr-anime.${env.domain}`)";
      "traefik.http.routers.bazarr-anime.entrypoints" = "websecure";
      "traefik.http.services.bazarr-anime.loadbalancer.server.port" = "6767";
    };

    ports = [
      "8001:6767"
    ];

    volumes = [
      "${env.config_dir}/bazarr-anime/config:/config"
      "${env.data_dir}:/data"
    ];
  };
}
