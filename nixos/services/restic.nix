{
  config,
  ...
}:
{
  services.restic.backups = {
    appdata = {
      # backupCleanupCommand
      # backupPrepareCommand
      passwordFile = config.sops.secrets."restic".path;

      exclude = [
        "*.log"
        "**/log/*"
        "**/logs/*"
      ];

      initialize = true;

      paths = [
        "/appdata"
      ];

      # pruneOpts = [
      #   "--keep-daily 7"
      #   "--keep-weekly 5"
      #   "--keep-monthly 12"
      # ];

      repository = "rclone:gcs:appdata";

      # timerConfig = {
      #   OnCalendar = "daily";
      #   Persistent = true;
      # };
    };
  };
}
