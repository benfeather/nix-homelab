{
  homeDirectory,
  host,
  pkgs,
  ...
}:
{
  home.stateVersion = "25.11";

  imports = [
    ./programs/git.nix
    ./programs/rclone.nix
  ];
}
