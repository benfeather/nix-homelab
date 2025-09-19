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
        "--logfile=/etc/cf-tunnel/logs/cloudflared.log"
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
        "${env.conf_dir}/cf-tunnel:/etc/cf-tunnel"
      ];
    };
  };
}
