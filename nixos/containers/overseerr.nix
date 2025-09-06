{
  config,
  ...
}:
let
  env = import ../utils/env.nix;
in
{
  virtualisation.oci-containers.containers."overseerr" = {
    image = "lscr.io/linuxserver/overseerr:latest";
    hostname = "overseerr";

    environment = {
      "PUID" = env.puid;
      "PGID" = env.pgid;
      "TZ" = env.tz;
    };

    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.overseerr.rule" = "Host(`overseerr.${env.domain}`)";
      "traefik.http.routers.overseerr.entrypoints" = "websecure";
      "traefik.http.services.overseerr.loadbalancer.server.port" = "5055";
    };

    networks = [
      "proxy"
    ];

    ports = [
      "8007:5055"
    ];

    volumes = [
      "${env.config_dir}/overseerr/config:/config"
    ];
  };
}
