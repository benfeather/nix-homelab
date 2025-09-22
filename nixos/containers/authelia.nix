{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "authelia" = {
      image = "authelia/authelia:latest";
      hostname = "authelia";

      environment = {
        "TZ" = env.tz;
      };

      environmentFiles = [
        config.sops.secrets."authelia".path
      ];

      labels = {
        "traefik.enable" = "true";
        "traefik.http.middlewares.authelia.forwardAuth.address" =
          "http://authelia:9091/api/verify?rd=https://auth.${env.domain}";
        "traefik.http.middlewares.authelia.forwardAuth.trustForwardHeader" = "true";
        "traefik.http.middlewares.authelia.forwardAuth.authResponseHeaders" =
          "Remote-User,Remote-Groups,Remote-Email,Remote-Name";
        "traefik.http.routers.authelia.entrypoints" = "websecure";
        "traefik.http.routers.authelia.rule" = "Host(`auth.${env.domain}`)";
        "traefik.http.routers.authelia.tls.certresolver" = "cloudflare";
        "traefik.http.services.authelia.loadbalancer.server.port" = "9091";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.appdata_dir}/authelia:/config"
      ];
    };
  };
}
