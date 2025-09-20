{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "jellyfin" = {
      hostname = "jellyfin";
      image = "lscr.io/linuxserver/jellyfin:latest";

      devices = [
        "/dev/dri:/dev/dri"
      ];

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.jellyfin.entrypoints" = "websecure";
        "traefik.http.routers.jellyfin.middlewares" = "authelia@docker";
        "traefik.http.routers.jellyfin.rule" = "Host(`jellyfin.${env.domain}`)";
        "traefik.http.services.jellyfin.loadbalancer.server.port" = "8096";
      };

      networks = [
        "proxy"
      ];

      ports = [
        "7359:7359/udp" # Local network discovery
        "1900:1900/udp" # DNLA discovery
      ];

      volumes = [
        "${env.conf_dir}/jellyfin/config:/config"
        "${env.data_dir}:/data"
      ];
    };
  };
}
