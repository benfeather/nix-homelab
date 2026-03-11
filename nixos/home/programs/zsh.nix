{
  env,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    zsh
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;

    initContent = ''
      eval "$(starship init zsh)"
    '';

    shellAliases = {
      cls = "clear";
      la = "ls -la";
      ll = "ls -l";
      rebuild = "sudo nixos-rebuild switch --flake ${env.root_dir}#nixos";
      upgrade = "sudo nixos-rebuild switch --flake ${env.root_dir}#nixos --upgrade";
    };
  };
}
