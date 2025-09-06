{
  config,
  ...
}:
let
  env = import ../utils/env.nix;
in
{
  virtualisation.oci-containers.containers."recyclarr" = {
    image = "recyclarr/recyclarr:latest";
    hostname = "recyclarr";

    environment = {
      "PUID" = env.puid;
      "PGID" = env.pgid;
      "TZ" = env.tz;
    };

    networks = [
      "proxy"
    ];

    volumes = [
      "${env.config_dir}/recyclarr/config:/config"
    ];
  };
}
