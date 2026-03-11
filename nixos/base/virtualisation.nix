{
  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = true;

      autoPrune = {
        enable = true;
        dates = "weekly";
      };

      daemon.settings.dns = [
        "1.1.1.1"
        "1.0.0.1"
      ];
    };

    oci-containers = {
      backend = "docker";
    };
  };
}
