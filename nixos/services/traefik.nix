{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "tailscale" = {
      image = "tailscale/tailscale";
      hostname = "traefik";

      environment = {
        "TS_AUTH_ONCE" = "true";
        "TS_STATE_DIR" = "/var/lib/tailscale";
        "TS_USERSPACE" = "false";
      };

      environmentFile = [
        "${config.sops.secrets.tailscale_env.path}"
      ];

      devices = [
        "/dev/net/tun:/dev/net/tun"
      ];

      extraOptions = [
        "--cap-add=net_admin"
        "--cap-add=sys_module"
      ];

      volumes = [
        "tailscale-data:/var/lib/tailscale"
      ];
    };

    "traefik" = {
      image = "traefik:v3";
      hostname = "traefik";

      environment = {
        "TZ" = env.tz;
        "CF_API_EMAIL" = env.cf_api_email;
      };

      environmentFile = [
        "${config.sops.secrets.traefik_env.path}"
      ];

      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock:ro"
        "traefik-certs:/certs"
      ];

      cmd = [
        # Docker provider
        "--providers.docker=true"
        "--providers.docker.exposedByDefault=false"

        # API dashboard
        "--api.dashboard=true"

        # Let's Encrypt via Cloudflare
        "--certificatesresolvers.letsencrypt.acme.dnschallenge=true"
        "--certificatesresolvers.letsencrypt.acme.dnschallenge.provider=cloudflare"
        "--certificatesresolvers.letsencrypt.acme.email=${env.le_email}"
        "--certificatesresolvers.letsencrypt.acme.storage=/certs/acme.json"

        # HTTP -> HTTPS redirect
        "--entrypoints.web.address=:80"
        "--entrypoints.web.http.redirections.entrypoint.to=websecure"
        "--entrypoints.web.http.redirections.entrypoint.scheme=https"

        # HTTPS entrypoint
        "--entrypoints.websecure.address=:443"
        "--entrypoints.websecure.http.tls=true"
        "--entrypoints.websecure.http.tls.certResolver=letsencrypt"
        "--entrypoints.websecure.http.tls.domains[0].main=${env.domain}"
        "--entrypoints.websecure.http.tls.domains[0].sans=${env.domain_sans}"
      ];

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.traefik.rule" = "Host(`traefik.${env.domain}`)";
        "traefik.http.routers.traefik.entrypoints" = "websecure";
        "traefik.http.routers.traefik.tls.certresolver" = "letsencrypt";
        "traefik.http.routers.traefik.service" = "api@internal";
        "traefik.http.services.traefik.loadbalancer.server.port" = "8080";
      };
    };
  };
}
