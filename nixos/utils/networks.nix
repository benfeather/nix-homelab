{
  pkgs,
  ...
}:
{
  systemd.services.networks = {
    path = [ pkgs.docker ];

    serviceConfig = {
      Type = "oneshot";
    }

    script = ''
      ${pkgs.docker}/bin/docker network inspect proxy || \
      ${pkgs.docker}/bin/docker network create --driver="bridge" proxy

      ${pkgs.docker}/bin/docker network inspect host || \
      ${pkgs.docker}/bin/docker network create --driver="host" host
    '';
    
    wantedBy = [
      "docker-tailscale.service"
      "docker-traefik.service"
    ];
  };
}
