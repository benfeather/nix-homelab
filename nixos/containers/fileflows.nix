{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "fileflows" = {
      hostname = "fileflows";
      image = "revenz/fileflows";

      devices = [
        "/dev/dri:/dev/dri"
      ];

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TempPathHost" = "/temp";
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.fileflows.entrypoints" = "websecure";
        "traefik.http.routers.fileflows.middlewares" = "authelia@docker";
        "traefik.http.routers.fileflows.rule" = "Host(`fileflows.${env.domain}`)";
        "traefik.http.services.fileflows.loadbalancer.server.port" = "5000";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock:ro"
        "${env.appdata_dir}/fileflows/config:/app/Data"
        "${env.appdata_dir}/fileflows/logs:/app/Logs"
        "${env.appdata_dir}/fileflows/temp:/temp"
        "${env.data_dir}:/data"
      ];
    };
  };
}
