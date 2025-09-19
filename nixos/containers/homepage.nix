{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers."homepage" = {
    image = "ghcr.io/gethomepage/homepage:latest";
    hostname = "homepage";

    environment = {
      "HOMEPAGE_ALLOWED_HOSTS" = "homepage.${env.domain}";
      "PUID" = env.puid;
      "PGID" = env.pgid;
      "TZ" = env.tz;
    };

    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.homepage.rule" = "Host(`homepage.${env.domain}`)";
      "traefik.http.routers.homepage.entrypoints" = "websecure";
      "traefik.http.services.homepage.loadbalancer.server.port" = "3000";
    };

    networks = [
      "proxy"
    ];

    ports = [
      "8016:3000"
    ];

    volumes = [
      "${env.conf_dir}/homepage/config:/app/config"
      "/var/run/docker.sock:/var/run/docker.sock:ro"
    ];
  };
}
