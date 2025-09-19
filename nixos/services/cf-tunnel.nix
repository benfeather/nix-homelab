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
        "--logfile=/etc/cloudflared/logs/cloudflared.log"
        "--loglevel=info"
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

      volumes = [
        "${env.conf_dir}/cloudflared:/etc/cloudflared"
      ];
    };
  };
}
