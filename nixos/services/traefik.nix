{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "tailscale" = {
      image = "tailscale/tailscale:latest";
      hostname = "homelab";

      environment = {
        "TS_AUTH_ONCE" = "true";
        "TS_STATE_DIR" = "/var/lib/tailscale";
      };

      environmentFiles = [
        "${config.sops.secrets.tailscale.path}"
      ];

      extraOptions = [
        "--cap-add=net_admin"
        "--cap-add=sys_module"
        "--restart=unless-stopped"
      ];

      devices = [
        "/dev/net/tun:/dev/net/tun"
        "${env.conf_dir}/tailscale/lib:/var/lib/tailscale"
      ];
    };

    "traefik" = {
      image = "traefik:latest";
      hostname = "traefik";

      environment = {
        "TZ" = env.tz;
      };

      extraOptions = [
        "--network=service:tailscale"
        "--restart=unless-stopped"
      ];

      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock:ro"
        "${env.conf_dir}/letsencrypt:/etc/letsencrypt:ro"
        "${env.conf_dir}/traefik:/etc/traefik"
      ];

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.dashboard.rule" = "Host(`traefik.${env.domain}`)";
        "traefik.http.routers.dashboard.service" = "api@internal";
        "traefik.http.routers.dashboard.entrypoints" = "websecure";
        "traefik.http.routers.dashboard.tls" = "true";
        "traefik.http.services.traefik.loadbalancer.server.port" = "8080";
      };
    };

    "whoami" = {
      image = "traefik/whoami:latest";
      hostname = "whoami";

      environment = {
        "TZ" = env.tz;
      };

      extraOptions = [
        "--restart=unless-stopped"
      ];

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.whoami.rule" = "Host(`whoami.${env.domain}`)";
        "traefik.http.routers.whoami.entrypoints" = "websecure";
        "traefik.http.routers.whoami.tls" = "true";
      };
    };

    "certbot" = {
      image = "certbot/dns-cloudflare:latest";
      hostname = "certbot";

      cmd = [
        "certonly"
        "--agree-tos"
        "--cert-name 'traefik'"
        "--dns-cloudflare "
        "--dns-cloudflare-credentials '/root/cloudflare.ini'"
        "--dns-cloudflare-propagation-seconds 15 "
        "--email '${env.email}'"
        "--keep-until-expiring"
        "--no-eff-email"
        "-d '${env.domain}'"
        "-d '*.${env.domain}'"
      ];

      environment = {
        "TZ" = env.tz;
      };

      volumes = [
        "${env.conf_dir}/letsencrypt:/etc/letsencrypt"
        "${config.sops.secrets.cloudflare.path}:/root/cloudflare.ini:ro"
      ];
    };
  };
}
