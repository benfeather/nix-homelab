{
  config,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    tailscale
  ];

  services.tailscale = {
    enable = true;
  };

  systemd.services.tailscale-autoconnect = {
    description = "Automatically connect to Tailscale";

    after = [
      "network-pre.target"
      "tailscale.service"
    ];

    wants = [
      "network-pre.target"
      "tailscale.service"
    ];

    wantedBy = [
      "multi-user.target"
    ];

    serviceConfig.Type = "oneshot";

    script = with pkgs; ''
      # wait for tailscaled to settle
      sleep 2

      # check if we are already authenticated to tailscale
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"

      if [ $status = "Running" ]; then
        exit 0
      fi

      # load TAILSCALE_AUTH_KEY from secrets file
      source ${config.sops.secrets."tailscale".path}

      # authenticate with tailscale
      ${tailscale}/bin/tailscale up --authkey "$TAILSCALE_AUTH_KEY" --ssh
    '';
  };
}
