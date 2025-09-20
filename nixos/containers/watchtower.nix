{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "watchtower" = {
      image = "containrrr/watchtower:latest";
      hostname = "watchtower";

      environment = {
        "TZ" = env.tz;
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
      ];
    };
  };
}
