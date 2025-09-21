{
  pkgs,
  ...
}:
let
  start-containers = pkgs.writeShellScriptBin "start-containers" ''
    services=$(systemctl list-unit-files --type=service | grep -E '^docker-.*\.service' | awk '{print $1}')

    for service in $services; do
      echo "Starting $service..."
      systemctl restart "$service"
    done
  '';

  stop-containers = pkgs.writeShellScriptBin "stop-containers" ''
    services=$(systemctl list-unit-files --type=service | grep -E '^docker-.*\.service' | awk '{print $1}')

    for service in $services; do
      echo "Stopping $service..."
      systemctl stop "$service"
    done
  '';
in
{
  environment.systemPackages = [ stop-containers ];
}
