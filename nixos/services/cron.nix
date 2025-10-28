{
  env,
  ...
}:
{
  services.cron = {
    enable = true;
    systemCronJobs = [
      "0 0 1-31/3 * *     root    backup-appdata"
      "0 1 * * *          root    oci-containers upgrade"
    ];
  };
}
