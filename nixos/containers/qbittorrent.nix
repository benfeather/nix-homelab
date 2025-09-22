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
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;

        "VPN_ENABLED" = "yes";
        "VPN_PROV" = "protonvpn";
        "VPN_CLIENT" = "openvpn";
        # "VPN_OPTIONS" = "<additional openvpn cli options>";
        # "ENABLE_STARTUP_SCRIPTS" = "<yes|no>";
        # "ENABLE_PRIVOXY" = "<yes|no>";
        # "STRICT_PORT_FORWARD" = "<yes|no>";
        # "USERSPACE_WIREGUARD" = "<yes|no>";
        # "ENABLE_SOCKS" = "<yes|no>";
        # "SOCKS_USER" = "<socks username>";
        # "SOCKS_PASS" = "<socks password>";
        "LAN_NETWORK" = "192.168.0.0/24";
        # "NAME_SERVERS" = "<name server ip(s)>";
        # "VPN_INPUT_PORTS" = "<port number(s)>";
        # "VPN_OUTPUT_PORTS" = "<port number(s)>";
        # "DEBUG" = "<true|false>";
        # "WEBUI_PORT" = "<port for web interfance>";
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

#     ports:
#       - "8080:8080"
#       - "8118:8118"
#       - "9118:9118"
#       - "58946:58946"
#       - "58946:58946/udp"
#     environment:
#       - VPN_ENABLED=<yes|no>
#       - VPN_USER=<vpn username>
#       - VPN_PASS=<vpn password>
#       - VPN_PROV=<pia|airvpn|protonvpn|custom>
#       - VPN_CLIENT=<openvpn|wireguard>
#       - VPN_OPTIONS=<additional openvpn cli options>
#       - ENABLE_STARTUP_SCRIPTS=<yes|no>
#       - ENABLE_PRIVOXY=<yes|no>
#       - STRICT_PORT_FORWARD=<yes|no>
#       - USERSPACE_WIREGUARD=<yes|no>
#       - ENABLE_SOCKS=<yes|no>
#       - SOCKS_USER=<socks username>
#       - SOCKS_PASS=<socks password>
#       - LAN_NETWORK=<lan ipv4 network>/<cidr notation>
#       - NAME_SERVERS=<name server ip(s)>
#       - VPN_INPUT_PORTS=<port number(s)>
#       - VPN_OUTPUT_PORTS=<port number(s)>
#       - DEBUG=<true|false>
#       - WEBUI_PORT=<port for web interfance>
