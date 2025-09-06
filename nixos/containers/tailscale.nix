{
  config,
  ...
}:
let
  env = import ../utils/env.nix;
in
{
  virtualisation.oci-containers.containers."tailscale" = {
    image = "tailscale/tailscale:latest";
    hostname = "tailscale";

    capabilities = {
      "NET_ADMIN" = true;
      "SYS_MODULE" = true;
    };

    environment = {
      "PUID" = env.puid;
      "PGID" = env.pgid;
      "TS_AUTHKEY" = config.sops.placeholder."global/tailscale_key";
      "TS_STATE_DIR" = "/config";
      "TS_USERSPACE" = "false";
      "TZ" = env.tz;
    };

    networks = [
      "host"
    ];

    volumes = [
      "${env.config_dir}/tailscale/config:/config"
    ];
  };
}
