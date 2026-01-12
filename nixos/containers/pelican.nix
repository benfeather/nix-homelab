{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "pelican-panel" = {
      hostname = "pelican-panel";
      image = "ghcr.io/pelican-dev/panel:latest";

      environment = {
        "ADMIN_EMAIL" = env.email;
        "APP_TIMEZONE" = env.tz;
        "APP_ENV" = "production";
        "APP_URL" = "https://pelican.${env.domain}";
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.pelican-panel.entrypoints" = "websecure";
        "traefik.http.routers.pelican-panel.rule" = "Host(`pelican.${env.domain}`)";
        "traefik.http.services.pelican-panel.loadbalancer.server.port" = "8080";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.appdata_dir}/pelican/caddyfile:/etc/caddy/caddyfile"
        "${env.appdata_dir}/pelican/data:/pelican-data"
        "${env.appdata_dir}/pelican/logs:/var/www/html/storage/logs"
      ];
    };
  };
}
