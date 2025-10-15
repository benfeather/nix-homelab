{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "deluge" = {
      hostname = "deluge";
      image = "ghcr.io/binhex/arch-delugevpn:latest";

      environment = {
        "LAN_NETWORK" = "192.168.0.0/24";
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
        "VPN_ENABLED" = "yes";
        "VPN_CLIENT" = "openvpn";
        "VPN_PROV" = "protonvpn";
        "VPN_USER" = "$VPN_USER";
        "VPN_PASS" = "$VPN_PASS";
      };

      environmentFiles = [
        config.sops.secrets."global".path
      ];

      extraOptions = [
        "--cap-add=NET_ADMIN"
      ];

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.deluge.entrypoints" = "websecure";
        "traefik.http.routers.deluge.rule" = "Host(`deluge.${env.domain}`)";
        "traefik.http.services.deluge.loadbalancer.server.port" = "8118";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.appdata_dir}/deluge:/config"
        "${env.data_dir}:/data"
      ];
    };
  };
}
