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

      environment = {
        "TZ" = env.tz;
      };

      # environmentFiles = [
      #   "${config.sops.secrets.cloudflare_env.path}"
      # ];

      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock:ro"
        "${env.config_dir}/traefik:/etc/traefik"
        "${env.config_dir}/tailscale/lib:/var/lib/tailscale"
        "${env.config_dir}/tailscale/run:/var/run/tailscale"
      ];

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.traefik_https.entrypoints" = "https";
        "traefik.http.routers.traefik_https.service" = "api@internal";
        "traefik.http.routers.traefik_https.tls" = "true";
        "traefik.http.routers.traefik_https.tls.certresolver" = "myresolver";
        "traefik.http.routers.traefik_https.tls.domains[0].main" = "traefik.mudpuppy-dorian.ts.net";
        "traefik.http.services.traefik.loadbalancer.server.port" = "443";
      };
    };
  };
}
