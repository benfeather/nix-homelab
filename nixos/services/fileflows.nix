{
  config,
  env,
  ...
}:
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
      "${env.conf_dir}/fileflows/data:/app/Data"
      "${env.conf_dir}/fileflows/logs:/app/Logs"
      "${env.conf_dir}/fileflows/temp:/temp"
      "${env.data_dir}:/data"
      "/var/run/docker.sock:/var/run/docker.sock:ro"
    ];
  };
}
