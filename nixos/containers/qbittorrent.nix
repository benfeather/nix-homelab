{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "qbittorrent" = {
      hostname = "qbittorrent";
      image = "ghcr.io/hotio/qbittorrent:latest";

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;

        "VPN_ENABLED" = "false";
        "VPN_CONF" = "wg0";
        "VPN_PROVIDER" = "proton";
        "VPN_LAN_NETWORK" = "192.168.1.0/24";
        "VPN_LAN_LEAK_ENABLED" = "false";
        "VPN_EXPOSE_PORTS_ON_LAN" = "";
        "VPN_AUTO_PORT_FORWARD" = "true";
        "VPN_AUTO_PORT_FORWARD_TO_PORTS" = "";
        "VPN_FIREWALL_TYPE" = "auto";
        "VPN_HEALTHCHECK_ENABLED" = "false";
        "VPN_NAMESERVERS" = "";
        "PRIVOXY_ENABLED" = "false";
        "UNBOUND_ENABLED" = "false";
        "UNBOUND_NAMESERVERS" = "";
      };

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
