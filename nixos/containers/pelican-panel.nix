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
        "APP_URL" = "https://pelican.${env.domain}";
        "XDG_DATA_HOME" = "/pelican-data";
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.pelican-panel.entrypoints" = "websecure";
        "traefik.http.routers.pelican-panel.rule" = "Host(`pelican.${env.domain}`)";
        "traefik.http.services.pelican-panel.loadbalancer.server.port" = "80";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.appdata_dir}/pelican/caddyfile:/etc/caddy/Caddyfile"
        "${env.appdata_dir}/pelican/data:/pelican-data"
        "${env.appdata_dir}/pelican/plugins:/var/www/html/plugins"
      ];
    };
  };
}
