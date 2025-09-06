{
  config,
  ...
}:
let
  env = import ../utils/env.nix;
in
{
  virtualisation.oci-containers.containers."duplicati" = {
    image = "lscr.io/linuxserver/bazarr:latest";
    hostname = "duplicati";

    environment = {
      "PUID" = env.puid;
      "PGID" = env.pgid;
      "TZ" = env.tz;
    };

    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.duplicati.rule" = "Host(`duplicati.${env.domain}`)";
      "traefik.http.routers.duplicati.entrypoints" = "websecure";
      "traefik.http.services.duplicati.loadbalancer.server.port" = "8200";
    };

    ports = [
      "8200:8200"
    ];

    volumes = [
      "${env.config_dir}/duplicati/config:/config"
      "${env.config_dir}:/source"
    ];
  };
}
