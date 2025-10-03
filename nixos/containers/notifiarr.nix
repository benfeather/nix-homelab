{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "notifiarr" = {
      hostname = "notifiarr";
      image = "docker.io/golift/notifiarr:latest";

      environment = {
        "DN_API_KEY" = "$NOTIFIARR_API_KEY";
        "TZ" = env.tz;
      };

      environmentFiles = [
        config.sops.secrets."global".path
      ];

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.notifiarr.entrypoints" = "websecure";
        "traefik.http.routers.notifiarr.rule" = "Host(`notifiarr.${env.domain}`)";
        "traefik.http.services.notifiarr.loadbalancer.server.port" = "5454";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.appdata_dir}/notifiarr:/config"
      ];
    };
  };
}
