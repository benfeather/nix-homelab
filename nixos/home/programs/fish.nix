{
  env,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    fish
  ];

  programs.fish = {
    enable = true;
    shellAliases = {
      cls = "clear";
      la = "ls -la";
      ll = "ls -l";
      rebuild = "sudo nixos-rebuild switch --flake ${env.root_dir}#nixos";
      upgrade = "sudo nixos-rebuild switch --flake ${env.root_dir}#nixos --upgrade";
    };
  };
}
