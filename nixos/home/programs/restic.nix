{
  osConfig,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    restic
  ];

  services.restic = {
    enable = true;

    backups."appdata" = {
      # backupCleanupCommand
      # backupPrepareCommand
      passwordFile = osConfig.sops.secrets."restic".path;
      exclude = [
        "*.log"
        "**/log/*"
        "**/logs/*"
      ];
      initialize = true;
      paths = [
        "/appdata"
      ];
      repository = "rclone:gcs:appdata";
      # timerConfig = {
      #   OnCalendar = "daily";
      #   Persistent = true;
      # };
    };
  };
}
