{
  env,
  ...
}:
{
  services.cron = {
    enable = true;
    systemCronJobs = [
      "0 1 * * *    root    backup-appdata"
    ];
  };
}
