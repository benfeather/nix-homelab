{
  pkgs,
  env,
  ...
}:
let
  fix-permissions = pkgs.writeShellScriptBin "fix-permissions" ''
    # Check if running as root, if not re-run with sudo
    if [ "$EUID" -ne 0 ]; then
      echo "This script requires root privileges. Re-running with sudo..."
      exec sudo "$0" "$@"
    fi

    echo "Fixing permissions in ${env.root_dir}..."
    chown -R ${env.puid}:users "${env.root_dir}"
    find "${env.root_dir}" -type d -exec chmod 700 {} \;
    find "${env.root_dir}" -type f -exec chmod 600 {} \;

    echo "Fixing permissions in ${env.appdata_dir}..."
    chown -R ${env.puid}:docker "${env.appdata_dir}"
    find "${env.appdata_dir}" -type d -exec chmod 770 {} \;
    find "${env.appdata_dir}" -type f -exec chmod 660 {} \;

    echo "Fixing special permissions..."
    chmod 600 ${env.appdata_dir}/traefik/acme.json
  '';
in
{
  environment.systemPackages = [
    fix-permissions
  ];
}
