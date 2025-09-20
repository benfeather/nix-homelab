{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "homepage" = {
      hostname = "homepage";
      image = "ghcr.io/gethomepage/homepage:latest";

      environment = {
        "HOMEPAGE_ALLOWED_HOSTS" = "home.${env.domain}";
        "HOMEPAGE_VAR_DOMAIN" = "${env.domain}";
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      environmentFiles = [
        config.sops.secrets."homepage".path
      ];

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.homepage.entrypoints" = "websecure";
        "traefik.http.routers.homepage.middlewares" = "authelia@docker";
        "traefik.http.routers.homepage.rule" = "Host(`home.${env.domain}`)";
        "traefik.http.services.homepage.loadbalancer.server.port" = "3000";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock:ro"
        "${env.conf_dir}/homepage/config:/app/config"
      ];
    };
  };
}
