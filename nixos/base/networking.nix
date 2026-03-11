{
  config,
  ...
}:
{
  networking = {
    firewall = {
      enable = true;

      allowedTCPPorts = [
        22 # SSH
      ];

      allowedUDPPorts = [
        config.services.tailscale.port
      ];

      trustedInterfaces = [
        "tailscale0"
      ];
    };

    hostName = "hydra";

    networkmanager.enable = true;
  };
}
