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
    chown -R ${env.puid}:users ${env.root_dir}
    find ${env.root_dir} -type d -exec chmod 750 {} \;
    find ${env.root_dir} -type f -exec chmod 640 {} \;
    echo "Permissions fixed."

    echo "Fixing permissions in ${env.appdata_dir}..."
    chown -R ${env.puid}:docker ${env.appdata_dir}
    find ${env.appdata_dir} -type d -exec chmod 777 {} \;
    find ${env.appdata_dir} -type f -exec chmod 666 {} \;
    echo "Permissions fixed."
  '';
in
{
  environment.systemPackages = [
    fix-permissions
  ];
}
