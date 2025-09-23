{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "notifiarr" = {
      hostname = "notifiarr";
      image = "docker.io/golift/notifiarr:latest";

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      environmentFiles = [
        config.sops.secrets."notifiarr".path
      ];

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.appdata_dir}/notifiarr:/config"
      ];
    };
  };
}
