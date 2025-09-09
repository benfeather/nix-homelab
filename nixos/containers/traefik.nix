{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "traefik" = {
      image = "traefik:v3";
      hostname = "traefik";

      cmd = [
        "--entrypoints.web.address=:80"
        "--entrypoints.web.http.redirections.entrypoint.to=websecure"
        "--entrypoints.web.http.redirections.entrypoint.scheme=https"
        "--entrypoints.web.http.redirections.entrypoint.permanent=true"
        "--entrypoints.websecure.address=:443"
        "--entrypoints.websecure.http.tls=true"
        "--providers.file.filename=/dynamic/tls.yaml"
        "--providers.docker=true"
        "--providers.docker.exposedbydefault=false"
        "--providers.docker.network=proxy"
        "--api.dashboard=true"
        "--api.insecure=false"
        "--log.level=INFO"
        "--accesslog=true"
        "--metrics.prometheus=true"
      ];

      environment = {
        "PUID" = env.puid;
        "PGID" = env.pgid;
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.dashboard.rule" = "Host(`dashboard.${env.domain}`)";
        "traefik.http.routers.dashboard.entrypoints" = "websecure";
        "traefik.http.routers.dashboard.service" = "api@internal";
        "traefik.http.routers.dashboard.tls" = "true";
      };

      networks = [
        "proxy"
      ];

      ports = [
        "80:80"
        "443:443"
        "3000:8080"
      ];

      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock:ro"
      ];
    };

    "traefik-whoami" = {
      image = "traefik/whoami";
      hostname = "traefik-whoami";

      environment = {
        "PUID" = env.puid;
        "PGID" = env.pgid;
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.whoami.rule" = "Host(`whoami.${env.domain}`)";
        "traefik.http.routers.whoami.entrypoints" = "websecure";
        "traefik.http.routers.whoami.tls" = "true";
      };
    };
  };
}
