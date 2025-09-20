{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "plex" = {
      hostname = "plex";
      image = "lscr.io/linuxserver/plex:latest";

      devices = [
        "/dev/dri:/dev/dri"
      ];

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      environmentFiles = [
        config.sops.secrets."plex".path
      ];

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.plex.entrypoints" = "websecure";
        # "traefik.http.routers.overseerr.middlewares" = "authelia@docker";
        "traefik.http.routers.plex.rule" = "Host(`plex.${env.domain}`)";
        "traefik.http.services.plex.loadbalancer.server.port" = "32400";
      };

      networks = [
        "proxy"
      ];

      ports = [
        "1900:1900/udp" # Plex DLNA discovery
        "5353:5353/udp" # Bonjour/Avahi network discovery
        "8324:8324" # Plex for Roku via Plex Companion
        "32410:32410/udp" # GDM network discovery
        "32412:32412/udp" # GDM network discovery
        "32413:32413/udp" # GDM network discovery
        "32414:32414/udp" # GDM network discovery
        "32469:32469" # Plex DLNA discovery
      ];

      volumes = [
        "${env.conf_dir}/plex/config:/config"
        "${env.data_dir}:/data"
      ];
    };
  };
}
