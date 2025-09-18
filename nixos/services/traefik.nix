{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "cf-tunnel" = {
      image = "cloudflare/cloudflared:latest";
      hostname = "cf-tunnel";

      environment = {
        "TUNNEL_HOSTNAME" = "*.${env.domain}";
        "TUNNEL_URL" = "https://traefik:443";
      };

      environmentFiles = [
        "${config.sops.secrets.cloudflare.path}"
      ];
    };

    "traefik" = {
      image = "traefik:latest";
      hostname = "traefik";

      environment = {
        "TZ" = env.tz;
      };

      environmentFiles = [
        "${config.sops.secrets.cloudflare.path}"
      ];

      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock:ro"
        "${env.conf_dir}/traefik:/etc/traefik"
      ];

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.traefik.entrypoints" = "websecure";
        "traefik.http.routers.traefik.middlewares" = "authelia@docker";
        "traefik.http.routers.traefik.rule" = "Host(`traefik.${env.domain}`)";
        "traefik.http.routers.traefik.service" = "api@internal";
        "traefik.http.routers.traefik.tls" = "true";
        "traefik.http.routers.traefik.tls.certresolver" = "cloudflare";
        "traefik.http.services.traefik.loadbalancer.server.port" = "8080";
      };
    };

    "whoami" = {
      image = "traefik/whoami:latest";
      hostname = "whoami";

      environment = {
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.whoami.entrypoints" = "websecure";
        "traefik.http.routers.traefik.middlewares" = "authelia@docker";
        "traefik.http.routers.whoami.rule" = "Host(`whoami.${env.domain}`)";
        "traefik.http.routers.whoami.tls" = "true";
      };
    };
  };
}
