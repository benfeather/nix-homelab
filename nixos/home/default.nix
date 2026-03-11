{
  env,
  pkgs,
  ...
}:
{
  imports = [
    ./programs/fish.nix
    ./programs/git.nix
    ./programs/rclone.nix
  ];

  home = {
    homeDirectory = "/home/${env.user}";
    stateVersion = "25.11";
    username = env.user;
  };
}
