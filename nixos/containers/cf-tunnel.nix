{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "cf-tunnel" = {
      image = "cloudflare/cloudflared:latest";
      hostname = "cf-tunnel";

      cmd = [
        "tunnel"
        "--no-autoupdate"
        "run"
      ];

      environment = {
        "TZ" = env.tz;
      };

      environmentFiles = [
        config.sops.secrets."cloudflare".path
      ];

      networks = [
        "proxy"
      ];
    };
  };
}
