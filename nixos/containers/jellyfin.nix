{
  config,
  ...
}:
let
  env = import ../utils/env.nix;
in
{
  virtualisation.oci-containers.containers."jellyfin" = {
    image = "lscr.io/linuxserver/jellyfin:latest";
    hostname = "jellyfin";

    # devices = [
    #   "/dev/dri:/dev/dri"
    # ];

    environment = {
      "PUID" = env.puid;
      "PGID" = env.pgid;
      "TZ" = env.tz;
    };

    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.jellyfin.rule" = "Host(`jellyfin.${env.domain}`)";
      "traefik.http.routers.jellyfin.entrypoints" = "websecure";
      "traefik.http.services.jellyfin.loadbalancer.server.port" = "8096";
    };

    networks = [
      "proxy"
    ];

    ports = [
      "8005:8096" # HTTP access
      "7359:7359/udp" # Local network discovery
      "1900:1900/udp" # DNLA discovery
    ];

    volumes = [
      "${env.config_dir}/jellyfin/config:/config"
      "${env.data_dir}:/data"
    ];
  };
}
