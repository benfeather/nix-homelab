{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "profilarr" = {
      hostname = "profilarr";
      image = "docker.io/santiagosayshey/profilarr:latest";

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.profilarr.entrypoints" = "websecure";
        "traefik.http.routers.profilarr.rule" = "Host(`profilarr.${env.domain}`)";
        "traefik.http.services.profilarr.loadbalancer.server.port" = "6868";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.appdata_dir}/profilarr:/config"
      ];
    };
  };
}
