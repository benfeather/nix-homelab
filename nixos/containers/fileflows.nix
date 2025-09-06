{
  config,
  ...
}:
let
  env = import ../utils/env.nix;
in
{
  virtualisation.oci-containers.containers."fileflows" = {
    image = "revenz/fileflows";
    hostname = "fileflows";

    # devices = [
    #   "/dev/dri:/dev/dri"
    # ];

    environment = {
      "PUID" = env.puid;
      "PGID" = env.pgid;
      "TempPathHost" = "/temp";
      "TZ" = env.tz;
    };

    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.fileflows.rule" = "Host(`fileflows.${env.domain}`)";
      "traefik.http.routers.fileflows.entrypoints" = "websecure";
      "traefik.http.services.fileflows.loadbalancer.server.port" = "5000";
    };

    networks = [
      "proxy"
    ];

    ports = [
      "8003:5000"
    ];

    volumes = [
      "${env.config_dir}/fileflows/data:/app/Data"
      "${env.config_dir}/fileflows/logs:/app/Logs"
      "${env.config_dir}/fileflows/temp:/temp"
      "${env.data_dir}:/data"
      "/var/run/docker.sock:/var/run/docker.sock:ro"
    ];
  };
}
