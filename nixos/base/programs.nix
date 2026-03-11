{
  env,
  pkgs,
  ...
}:
{
  environment = {
    shells = with pkgs; [
      zsh
    ];

    systemPackages = with pkgs; [
      curl
      git
      nano
      nixd
      nixfmt
      rclone
      restic
      sops
      zsh
    ];
  };

  home-manager = {
    extraSpecialArgs = {
      inherit env;
    };
    users.${env.user} = import ../home/default.nix;
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  programs.zsh.enable = true;
}
