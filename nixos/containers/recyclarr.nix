{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "recyclarr" = {
      hostname = "recyclarr";
      image = "recyclarr/recyclarr:latest";

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.conf_dir}/recyclarr/config:/config"
      ];
    };
  };
}
