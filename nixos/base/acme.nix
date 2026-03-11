{
  config,
  env,
  ...
}:
{
  security.acme = {
    acceptTerms = true;

    defaults.email = env.email;

    certs."${env.domain}" = {
      domain = "*.${env.domain}";
      dnsProvider = "cloudflare";
      environmentFile = config.sops.secrets."cloudflare".sopsFile;
    };
  };
}
