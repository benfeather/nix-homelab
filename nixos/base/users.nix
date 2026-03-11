{
  env,
  pkgs,
  ...
}:
{
  users.users.${env.user} = {
    extraGroups = [
      "docker"
      "networkmanager"
      "video"
      "wheel"
    ];

    isNormalUser = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDRN844nMraLIO6ZSO5XlxVOd2va3pnnJMC/BRS41zIo"
    ];

    shell = pkgs.fish;
  };
}
