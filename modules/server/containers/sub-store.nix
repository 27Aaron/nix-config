{
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.containers'.sub-store;
in {
  options.containers'.sub-store = {
    enable = lib.mkEnableOption "Enable sub-store web server";

    domain = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Domain name to serve sub-store on via Caddy.";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.sub-store_backend_path = {
      sopsFile = "${inputs.my-secrets}/services/sub-store.yaml";
    };

    sops.templates."sub-store.env".content = ''
      SUB_STORE_FRONTEND_BACKEND_PATH=${config.sops.placeholder.sub-store_backend_path}
    '';

    systemd.tmpfiles.rules = [
      "d /var/lib/sub-store 0755 root root -"
    ];

    virtualisation.oci-containers.containers = {
      sub-store = {
        hostname = "sub-store";
        serviceName = "sub-store";
        image = "xream/sub-store:http-meta";
        ports = ["127.0.0.1:3001:3001"];
        environmentFiles = [
          config.sops.templates."sub-store.env".path
        ];
        environment = {
          HOST = "127.0.0.1";
          PORT = "9876";
          SUB_STORE_BACKEND_API_HOST = "127.0.0.1";
          SUB_STORE_BACKEND_API_PORT = "3000";
          SUB_STORE_FRONTEND_HOST = "0.0.0.0";
          SUB_STORE_FRONTEND_PORT = "3001";
        };
        volumes = ["/var/lib/sub-store:/opt/app/data"];
        extraOptions = [
          "--tty"
          "--interactive"
          "--memory=256m"
        ];
        autoStart = true;
      };
    };

    preservation'.os.directories = [
      "/var/lib/sub-store"
    ];

    services.caddy.virtualHosts = lib.mkIf (cfg.domain != null) {
      "${cfg.domain}" = {
        extraConfig = ''
          encode zstd gzip
          reverse_proxy 127.0.0.1:3001 {
            import cloudflare_headers
          }
        '';
      };
    };
  };
}
