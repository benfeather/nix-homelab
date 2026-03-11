{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    git
  ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "Ben Feather";
      user.email = "contact@benfeather.dev";
      init.defaultBranch = "master";
    };
  };
}
