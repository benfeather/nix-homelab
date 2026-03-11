{
  osConfig,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    rclone
  ];

  programs.rclone = {
    enable = true;
    remotes = {
      gcs = {
        config = {
          type = "google cloud storage";
          service_account_file = osConfig.sops.secrets."gcs".path;
        };
      };
    };
  };
}
