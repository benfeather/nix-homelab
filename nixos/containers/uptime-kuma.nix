{
  config,
  ...
}:
let
  env = import ../utils/env.nix;
in
{
  virtualisation.oci-containers.containers."uptime" = {
    image = "louislam/uptime-kuma:alpine";
    hostname = "uptime";

    environment = {
      "PUID" = env.puid;
      "PGID" = env.pgid;
      "TZ" = env.tz;
    };

    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.uptime.rule" = "Host(`uptime.${env.domain}`)";
      "traefik.http.routers.uptime.entrypoints" = "websecure";
      "traefik.http.services.uptime.loadbalancer.server.port" = "3001";
    };

    networks = [
      "proxy"
    ];

    ports = [
      "8015:3001"
    ];

    volumes = [
      "${env.config_dir}/uptime/config:/app/data"
    ];
  };
}
