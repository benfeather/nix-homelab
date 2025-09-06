{
  config,
  ...
}:
let
  env = import ../utils/env.nix;
in
{
  virtualisation.oci-containers.containers."plex" = {
    image = "lscr.io/linuxserver/plex:latest";
    hostname = "plex";

    # devices = [
    #   "/dev/dri:/dev/dri"
    # ];

    environment = {
      "PLEX_CLAIM" = config.sops.placeholder."global/plex_claim";
      "PUID" = env.puid;
      "PGID" = env.pgid;
      "TZ" = env.tz;
    };

    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.plex.rule" = "Host(`plex.${env.domain}`)";
      "traefik.http.routers.plex.entrypoints" = "websecure";
      "traefik.http.services.plex.loadbalancer.server.port" = "32400";
    };

    networks = [
      "proxy"
    ];

    ports = [
      "8008:32400"
      "1900:1900"
      "5353:5353/udp"
      "8324:8324"
      "32410:32410/udp"
      "32412:32412/udp"
      "32413:32413/udp"
      "32414:32414/udp"
      "32469:32469"
    ];

    volumes = [
      "${env.config_dir}/plex/config:/config"
      "${env.data_dir}:/data"
    ];
  };
}
