{
  config,
  env,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "stirling-pdf" = {
      hostname = "stirling-pdf";
      image = "docker.stirlingpdf.com/stirlingtools/stirling-pdf:latest";

      environment = {
        "DISABLE_ADDITIONAL_FEATURES" = "false";
        "LANGS" = "en_NZ";
        "PGID" = env.pgid;
        "PUID" = env.puid;
        "TZ" = env.tz;
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.pdf.entrypoints" = "websecure";
        "traefik.http.routers.pdf.rule" = "Host(`pdf.${env.domain}`)";
        "traefik.http.services.pdf.loadbalancer.server.port" = "8080";
      };

      networks = [
        "proxy"
      ];

      volumes = [
        "${env.appdata_dir}/stirling-pdf/trainingData:/usr/share/tessdata"
        "${env.appdata_dir}/stirling-pdf/configs:/configs"
        "${env.appdata_dir}/stirling-pdf/customFiles:/customFiles"
        "${env.appdata_dir}/stirling-pdf/logs:/logs"
        "${env.appdata_dir}/stirling-pdf/pipeline:/pipeline"
      ];
    };
  };
}
