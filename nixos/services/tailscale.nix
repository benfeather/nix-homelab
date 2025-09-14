{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "tailscale" = {
      image = "tailscale/tailscale";
      hostname = "tailscale";

      environment = {
        "TS_AUTH_ONCE" = "true";
        "TS_STATE_DIR" = "/var/lib/tailscale";
        "TS_SOCKET" = "/var/run/tailscale/tailscaled.sock";
        "TS_USERSPACE" = "false";
      };

      environmentFiles = [
        "${config.sops.secrets.tailscale_env.path}"
      ];

      devices = [
        "/dev/net/tun:/dev/net/tun"
        "${env.config_dir}/tailscale/lib:/var/lib/tailscale"
        "${env.config_dir}/tailscale/run:/var/run/tailscale"
      ];

      extraOptions = [
        "--cap-add=net_admin"
        "--cap-add=sys_module"
      ];

      volumes = [
        "tailscale-data:/var/lib/tailscale"
      ];
    };
  };
}
