{
  config,
  ...
}:
let
  env = import ../utils/env.nix;
in
{
  virtualisation.oci-containers.containers."prowlarr" = {
    image = "lscr.io/linuxserver/prowlarr:latest";
    hostname = "prowlarr";

    environment = {
      "PUID" = env.puid;
      "PGID" = env.pgid;
      "TZ" = env.tz;
    };

    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.prowlarr.rule" = "Host(`prowlarr.${env.domain}`)";
      "traefik.http.routers.prowlarr.entrypoints" = "websecure";
      "traefik.http.services.prowlarr.loadbalancer.server.port" = "9696";
    };

    networks = [
      "proxy"
    ];

    ports = [
      "8009:9696"
    ];

    volumes = [
      "${env.config_dir}/prowlarr/config:/config"
    ];
  };
}
