{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "flaresolverr" = {
      hostname = "flaresolverr";
      image = "ghcr.io/flaresolverr/flaresolverr:latest";

      environment = {
        "LOG_LEVEL" = "info";
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };
    };
  };
}
