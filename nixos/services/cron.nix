{
  env,
  ...
}:
{
  services.cron = {
    enable = true;
    systemCronJobs = [
      "0 1 * * *    root    backup-appdata"
      "0 2 * * *    root    oci-containers upgrade"
    ];
  };
}
