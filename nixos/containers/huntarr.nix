{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers."huntarr" = {
    image = "huntarr/huntarr:latest";
    hostname = "huntarr";

    environment = {
      "PUID" = env.puid;
      "PGID" = env.pgid;
      "TZ" = env.tz;
    };

    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.huntarr.rule" = "Host(`huntarr.${env.domain}`)";
      "traefik.http.routers.huntarr.entrypoints" = "websecure";
      "traefik.http.services.huntarr.loadbalancer.server.port" = "9705";
    };

    networks = [
      "proxy"
    ];

    ports = [
      "8004:9705"
    ];

    volumes = [
      "${env.conf_dir}/huntarr/config:/config"
    ];
  };
}
