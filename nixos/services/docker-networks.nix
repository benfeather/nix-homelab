{
  pkgs,
  ...
}:
{
  systemd.services.docker-networks = {
    serviceConfig = {
      Type = "oneshot";
    };

    script = ''
      ${pkgs.docker}/bin/docker network inspect backend || \
      ${pkgs.docker}/bin/docker network create --driver="bridge" backend

      ${pkgs.docker}/bin/docker network inspect proxy || \
      ${pkgs.docker}/bin/docker network create --driver="bridge" proxy

      ${pkgs.docker}/bin/docker network inspect host || \
      ${pkgs.docker}/bin/docker network create --driver="host" host
    '';

    wantedBy = [
      "docker-authelia.service"
      "docker-cf-tunnel.service"
      "docker-traefik.service"
    ];
  };
}
