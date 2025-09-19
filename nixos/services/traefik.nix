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

      cmd = [
        "tunnel"
        "--config=/etc/cloudflared/config.yml"
        "--logfile=/etc/cloudflared/cloudflared.log"
        "--loglevel=debug"
        "--no-autoupdate"
        "run"
      ];

      environment = {
        "TZ" = env.tz;
      };

      environmentFiles = [
        config.sops.secrets."cloudflare".path
      ];

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.conf_dir}/cloudflared:/etc/cloudflared"
      ];
    };

    "traefik" = {
      image = "traefik:latest";
      hostname = "traefik";

      environment = {
        "TZ" = env.tz;
      };

      environmentFiles = [
        config.sops.secrets."cloudflare".path
      ];

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.traefik.entrypoints" = "websecure";
        # "traefik.http.routers.traefik.middlewares" = "authelia@docker";
        "traefik.http.routers.traefik.rule" = "Host(`traefik.${env.domain}`)";
        "traefik.http.routers.traefik.service" = "api@internal";
        "traefik.http.routers.traefik.tls" = "true";
        "traefik.http.routers.traefik.tls.certresolver" = "cloudflare";
        "traefik.http.services.traefik.loadbalancer.server.port" = "8080";
      };

      networks = [
        "proxy"
      ];

      ports = [
        "80:80"
        "443:443"
      ];

      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock:ro"
        "${env.conf_dir}/traefik:/etc/traefik"
      ];
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
        # "traefik.http.routers.whoami.middlewares" = "authelia@docker";
        "traefik.http.routers.whoami.rule" = "Host(`whoami.${env.domain}`)";
        "traefik.http.routers.whoami.tls" = "true";
      };

      networks = [
        "proxy"
      ];
    };
  };
}
