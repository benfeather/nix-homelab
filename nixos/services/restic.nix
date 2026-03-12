{
  config,
  ...
}:
{
  services.restic.backups = {
    appdata = {
      backupCleanupCommand = "oci-containers start";

      backupPrepareCommand = "oci-containers stop";

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

      rcloneConfig = {
        type = "google cloud storage";
        service_account_file = config.sops.secrets."gcs".path;
      };

      repository = "rclone:gcs:appdata";

      # timerConfig = {
      #   OnCalendar = "daily";
      #   Persistent = true;
      # };
    };
  };
}
