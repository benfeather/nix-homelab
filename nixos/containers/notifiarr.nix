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
        "TZ" = env.tz;
      };

      environmentFiles = [
        config.sops.secrets."notifiarr".path
      ];

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.notifiarr.entrypoints" = "websecure";
        # "traefik.http.routers.notifiarr.middlewares" = "authelia@docker";
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
