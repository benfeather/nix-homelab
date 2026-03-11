{
  env,
  ...
}:
{
  system.stateVersion = "25.11";

  time.timeZone = env.tz;
}
