{
  env,
  pkgs,
  ...
}:
let
  backup-appdata = pkgs.writeShellScriptBin "backup-appdata" ''
    oci-containers stop

    archive ${env.conf_dir} ${env.backup_dir}

    archive-cleanup ${env.backup_dir}

    rclone-sync ${env.backup_dir} backups

    oci-containers start
  '';
in
{
  environment.systemPackages = [
    backup-appdata
  ];
}
