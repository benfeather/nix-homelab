{
  config,
  env,
  pkgs,
  ...
}:
{
  services.restic.backups = {
    appdata = {
      # Start containers after the backup finishes (success or failure)
      backupCleanupCommand = ''
        echo "Restarting Docker containers..."

        for unit in $(${pkgs.systemd}/bin/systemctl list-unit-files --type=service 2>/dev/null \
          | ${pkgs.gnugrep}/bin/grep -E '^docker-.*\.service' \
          | ${pkgs.gawk}/bin/awk '{print $1}' || true); \
        do
          ${pkgs.systemd}/bin/systemctl start "$unit"
        done
      '';

      # Stop containers before the backup starts
      backupPrepareCommand = ''
        echo "Stopping Docker containers..."
        ${pkgs.systemd}/bin/systemctl stop "docker-*.service"
      '';

      exclude = [
        "*.log"
      ];

      extraBackupArgs = [
        "--iexclude=**/backup/*"
        "--iexclude=**/backups/*"
        "--iexclude=**/cache/*"
        "--iexclude=**/log/*"
        "--iexclude=**/logs/*"
        "--iexclude=**/temp/*"
      ];

      initialize = true;

      passwordFile = config.sops.secrets."restic".path;

      paths = [
        "/appdata"
      ];

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
      ];

      rcloneConfig = {
        type = "google cloud storage";
        service_account_file = config.sops.secrets."gcs".path;
        bucket_policy_only = "true";
      };

      repository = "rclone:appdata:${env.backup_bucket}/appdata";

      runCheck = true;

      timerConfig = {
        OnCalendar = "01:00:00";
        Persistent = true;
      };
    };
  };
}
