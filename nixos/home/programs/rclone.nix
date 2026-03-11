{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    rclone
  ];

  programs.rclone = {
    enable = true;
  };
}
