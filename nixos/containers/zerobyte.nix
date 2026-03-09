{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "zerobyte" = {
      hostname = "zerobyte";
      image = "ghcr.io/nicotsx/zerobyte:latest";

      devices = [
        "/dev/fuse:/dev/fuse"
      ];

      environment = {
        "BASE_URL" = "https://zerobyte.${env.domain}";
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      environmentFiles = [
        config.sops.secrets."zerobyte".path
      ];

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.zerobyte.entrypoints" = "websecure";
        "traefik.http.routers.zerobyte.rule" = "Host(`zerobyte.${env.domain}`)";
        "traefik.http.services.zerobyte.loadbalancer.server.port" = "4096";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "/etc/localtime:/etc/localtime:ro"
        "${env.appdata_dir}/zerobyte:/var/lib/zerobyte"
        "${env.data_dir}:/data"
      ];
    };
  };
}
