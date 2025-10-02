{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "sabnzbd" = {
      hostname = "sabnzbd";
      image = "lscr.io/linuxserver/sabnzbd:latest";

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.sabnzbd.entrypoints" = "websecure";
        "traefik.http.routers.sabnzbd.rule" = "Host(`sabnzbd.${env.domain}`)";
        "traefik.http.services.sabnzbd.loadbalancer.server.port" = "8080";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.appdata_dir}/sabnzbd:/config"
        "${env.data_dir}:/data"
      ];
    };
  };
}
