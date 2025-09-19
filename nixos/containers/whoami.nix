{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "whoami" = {
      image = "traefik/whoami:latest";
      hostname = "whoami";

      environment = {
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.whoami.entrypoints" = "websecure";
        "traefik.http.routers.whoami.middlewares" = "authelia@docker";
        "traefik.http.routers.whoami.rule" = "Host(`whoami.${env.domain}`)";
        "traefik.http.routers.whoami.tls" = "true";
      };

      networks = [
        "proxy"
      ];
    };
  };
}
