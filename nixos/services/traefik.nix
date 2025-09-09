{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers = {
    containers = {
      "tailscale" = {
        image = "tailscale/tailscale";
        hostname = "traefik"; # matches compose
        restartPolicy = "unless-stopped";

        # Environment mirrors the compose values; TS_AUTHKEY should come from env.*
        environment = {
          "TS_AUTH_ONCE" = "true";
          "TS_AUTHKEY" = env.ts_authkey;
          "TS_STATE_DIR" = "/var/lib/tailscale";
          "TS_USERSPACE" = "false";
        };

        # Devices and capabilities required for kernel-mode Tailscale
        # (TS_USERSPACE=false). On NixOS, ensure the TUN device exists.
        devices = [
          "/dev/net/tun:/dev/net/tun"
        ];

        extraCapabilities = [
          "NET_ADMIN"
          "SYS_MODULE"
        ];

        volumes = [
          "tailscale-data:/var/lib/tailscale"
        ];
      };

      "traefik" = {
        image = "traefik:v3";
        hostname = "traefik";
        restartPolicy = "unless-stopped";

        environment = {
          "TZ" = env.tz;
          "CF_API_EMAIL" = env.cf_api_email;
          "CF_DNS_API_TOKEN" = env.cf_dns_api_token;
          "CF_ZONE_API_TOKEN" = env.cf_dns_api_token;
        };

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

          # Let's Encrypt via Cloudflare DNS-01
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

    # volumes = {
    #   "tailscale-data" = { };
    #   "traefik-certs" = { };
    # };
  };
}
