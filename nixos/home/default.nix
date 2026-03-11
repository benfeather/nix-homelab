{
  env,
  ...
}:
{
  imports = [
    ./programs/git.nix
    ./programs/rclone.nix
    ./programs/starship.nix
    ./programs/zsh.nix
  ];

  home = {
    homeDirectory = "/home/${env.user}";
    stateVersion = "25.11";
    username = env.user;
  };
}
