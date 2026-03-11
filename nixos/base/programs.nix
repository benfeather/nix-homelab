{
  env,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    curl
    fish
    git
    nano
    nixfmt-rfc-style
    sops
  ];

  home-manager = {
    extraSpecialArgs = {
      inherit env;
    };
    users.${env.user} = import ../home/default.nix;
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  programs.fish.enable = true;
}
