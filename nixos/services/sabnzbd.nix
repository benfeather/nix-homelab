{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers."sabnzbd" = {
    image = "lscr.io/linuxserver/sabnzbd:latest";
    hostname = "sabnzbd";

    environment = {
      "PUID" = env.puid;
      "PGID" = env.pgid;
      "TZ" = env.tz;
    };

    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.sabnzbd.rule" = "Host(`sabnzbd.${env.domain}`)";
      "traefik.http.routers.sabnzbd.entrypoints" = "websecure";
      "traefik.http.services.sabnzbd.loadbalancer.server.port" = "8080";
    };

    networks = [
      "proxy"
    ];

    ports = [
      "8012:8080"
    ];

    volumes = [
      "${env.config_dir}/sabnzbd/config:/config"
      "${env.data_dir}:/data"
    ];
  };
}
