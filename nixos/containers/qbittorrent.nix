{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "qbittorrent" = {
      hostname = "qbittorrent";
      image = "ghcr.io/binhex/arch-qbittorrentvpn:latest";

      environment = {
        "LAN_NETWORK" = "192.168.0.0/24";
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
        "VPN_ENABLED" = "yes";
        "VPN_PROV" = "protonvpn";
        "VPN_CLIENT" = "openvpn";
      };

      environmentFiles = [
        config.sops.secrets."vpn".path
      ];

      extraOptions = [
        "--cap-add=NET_ADMIN"
      ];

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.qbittorrent.entrypoints" = "websecure";
        # "traefik.http.routers.qbittorrent.middlewares" = "authelia@docker";
        "traefik.http.routers.qbittorrent.rule" = "Host(`qbittorrent.${env.domain}`)";
        "traefik.http.services.qbittorrent.loadbalancer.server.port" = "8080";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.appdata_dir}/qbittorrent:/config"
        "${env.data_dir}:/data"
      ];
    };
  };
}
