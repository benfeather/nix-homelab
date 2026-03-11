{ env, ... }:
{
  sops = {
    age.keyFile = "/home/${env.user}/.config/sops/age/keys.txt";

    secrets = {
      "authelia" = {
        format = "dotenv";
        sopsFile = ../secrets/authelia.env;
        key = "";
      };

      "cloudflare" = {
        format = "dotenv";
        sopsFile = ../secrets/cloudflare.env;
        key = "";
      };

      "dockpeek" = {
        format = "dotenv";
        sopsFile = ../secrets/dockpeek.env;
        key = "";
      };

      "gcs" = {
        format = "json";
        sopsFile = ../secrets/gcs.json;
        key = "";
        owner = env.user;
        group = "users";
        mode = "0400";
      };

      "homepage" = {
        format = "dotenv";
        sopsFile = ../secrets/homepage.env;
        key = "";
      };

      "immich" = {
        format = "dotenv";
        sopsFile = ../secrets/immich.env;
        key = "";
      };

      "restic" = {
        format = "binary";
        sopsFile = ../secrets/restic.txt;
        key = "";
      };

      "romm" = {
        format = "dotenv";
        sopsFile = ../secrets/romm.env;
        key = "";
      };

      "tailscale" = {
        format = "dotenv";
        sopsFile = ../secrets/tailscale.env;
        key = "";
      };

      "zerobyte" = {
        format = "dotenv";
        sopsFile = ../secrets/zerobyte.env;
        key = "";
      };
    };
  };
}
