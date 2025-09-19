{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "traefik" = {
      image = "traefik:latest";
      hostname = "traefik";

      cmd = [
        "--global.checknewversion=true"
        "--global.sendanonymoususage=false"

        "--api.dashboard=true"

        "--log.level=INFO"
        "--log.filepath=/etc/traefik/logs/traefik.log"

        "--accesslog=true"
        "--accesslog.filepath=/etc/traefik/logs/access.log"

        "--entrypoints.web.address=:80"
        "--entrypoints.web.http.redirections.entrypoint.to=websecure"
        "--entrypoints.web.http.redirections.entrypoint.scheme=https"
        "--entrypoints.web.http.redirections.entrypoint.permanent=true"

        "--entrypoints.websecure.address=:443"
        "--entrypoints.websecure.http.tls=true"
        "--entrypoints.websecure.http.tls.certresolver=cloudflare"
        "--entrypoints.websecure.http.tls.domains[0].main=${env.domain}"
        "--entrypoints.websecure.http.tls.domains[0].sans=*.${env.email}"

        "--providers.docker=true"
        "--providers.docker.endpoint=unix:///var/run/docker.sock"
        "--providers.docker.exposedbydefault=false"
        "--providers.docker.watch=true"

        "--certificatesresolvers.cloudflare.acme.email=${env.email}"
        "--certificatesresolvers.cloudflare.acme.dnschallenge=true"
        "--certificatesresolvers.cloudflare.acme.dnschallenge.provider=cloudflare"
      ];

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

      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock:ro"
        "${env.conf_dir}/traefik:/etc/traefik"
      ];
    };
  };
}
