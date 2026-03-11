{
  config,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    rclone
  ];

  services.rclone = {
    enable = true;
  };
}
