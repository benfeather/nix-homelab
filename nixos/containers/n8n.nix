{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "n8n" = {
      hostname = "n8n";
      image = "docker.n8n.io/n8nio/n8n:latest";

      environment = {
        "GENERIC_TIMEZONE" = env.tz;
        "N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS" = "true";
        "N8N_HOST" = "n8n.${env.domain}";
        "N8N_PORT" = "5678";
        "N8N_PROTOCOL" = "https";
        "N8N_RUNNERS_ENABLED" = "true";
        "NODE_ENV" = "production";
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
        "WEBHOOK_URL" = "https://n8n.${env.domain}/";
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.middlewares.n8n.headers.SSLRedirect" = "true";
        "traefik.http.middlewares.n8n.headers.STSSeconds" = "315360000";
        "traefik.http.middlewares.n8n.headers.browserXSSFilter" = "true";
        "traefik.http.middlewares.n8n.headers.contentTypeNosniff" = "true";
        "traefik.http.middlewares.n8n.headers.forceSTSHeader" = "true";
        "traefik.http.middlewares.n8n.headers.SSLHost" = "${env.domain}";
        "traefik.http.middlewares.n8n.headers.STSIncludeSubdomains" = "true";
        "traefik.http.middlewares.n8n.headers.STSPreload" = "true";
        "traefik.http.routers.n8n.rule" = "Host(`n8n.${env.domain}`)";
        "traefik.http.routers.n8n.entrypoints" = "websecure";
        "traefik.http.routers.n8n.middlewares" = "n8n@docker";
        "traefik.http.services.n8n.loadbalancer.server.port" = "5678";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.appdata_dir}/n8n/config:/home/node/.n8n"
        "${env.appdata_dir}/n8n/files:/files"
      ];
    };
  };
}
