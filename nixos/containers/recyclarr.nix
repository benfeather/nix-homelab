{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "recyclarr" = {
      hostname = "recyclarr";
      image = "ghcr.io/recyclarr/recyclarr:latest";

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.appdata_dir}/recyclarr/config:/config"
      ];
    };
  };
}
