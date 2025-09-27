{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "cloud" = {
      hostname = "cloud";
      image = "docker.io/opencloudeu/opencloud:latest";

      cmd = [
        "/bin/sh -c opencloud init || true; opencloud server"
      ];

      environment = {
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;

        "OC_ADD_RUN_SERVICES" = "true";
        "OC_URL" = "https://cloud.${env.domain}";
        "OC_LOG_LEVEL" = "info";
        "OC_LOG_COLOR" = "false";
        "OC_LOG_PRETTY" = "false";
        "PROXY_TLS" = "false";
        "OC_INSECURE" = "false";
        "PROXY_ENABLE_BASIC_AUTH" = "false";
        "IDM_CREATE_DEMO_USERS" = "false";
        "IDM_ADMIN_PASSWORD" = "admin";
        # "NOTIFICATIONS_SMTP_HOST" = "$SMTP_HOST";
        # "NOTIFICATIONS_SMTP_PORT" = "$SMTP_PORT";
        # "NOTIFICATIONS_SMTP_SENDER" = "$SMTP_SENDER";
        # "NOTIFICATIONS_SMTP_USERNAME" = "$SMTP_USERNAME";
        # "NOTIFICATIONS_SMTP_PASSWORD" = "$SMTP_PASSWORD";
        # "NOTIFICATIONS_SMTP_INSECURE" = "$SMTP_INSECURE";
        # "NOTIFICATIONS_SMTP_AUTHENTICATION" = "$SMTP_AUTHENTICATION";
        # "NOTIFICATIONS_SMTP_ENCRYPTION" = "$SMTP_TRANSPORT_ENCRYPTION";
        "FRONTEND_ARCHIVER_MAX_SIZE" = "10000000000";
        "PROXY_CSP_CONFIG_FILE_LOCATION" = "/etc/opencloud/csp.yaml";
        "OC_PASSWORD_POLICY_BANNED_PASSWORDS_LIST" = "banned-password-list.txt";
        "OC_SHARING_PUBLIC_SHARE_MUST_HAVE_PASSWORD" = "true";
        "OC_SHARING_PUBLIC_WRITEABLE_SHARE_MUST_HAVE_PASSWORD" = "true";
        "OC_PASSWORD_POLICY_DISABLED" = "false";
        "OC_PASSWORD_POLICY_MIN_CHARACTERS" = "8";
        "OC_PASSWORD_POLICY_MIN_LOWERCASE_CHARACTERS" = "1";
        "OC_PASSWORD_POLICY_MIN_UPPERCASE_CHARACTERS" = "1";
        "OC_PASSWORD_POLICY_MIN_DIGITS" = "1";
        "OC_PASSWORD_POLICY_MIN_SPECIAL_CHARACTERS" = "1";
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.opencloud.entrypoints" = "websecure";
        "traefik.http.routers.opencloud.rule" = "Host(`cloud.${env.domain}`)";
        "traefik.http.services.opencloud.loadbalancer.server.port" = "8686";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.appdata_dir}/opencloud/apps:/var/lib/opencloud/web/assets/apps"
        "${env.appdata_dir}/opencloud/config:/etc/opencloud"
        "${env.data_dir}:/var/lib/opencloud"
      ];
    };
  };
}
