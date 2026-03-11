{
  nix = {
    channel.enable = false;

    settings = {
      experimental-features = "nix-command flakes";
    };

    gc = {
      automatic = true;
      dates = "03:00";
      options = "--delete-older-than 7d";
    };
  };

  nixpkgs.config.allowUnfree = true;
}
