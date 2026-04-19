{
  lib,
  config,
  ...
}: let
  cfg = config.containers'.new-api;
in {
  options.containers'.new-api = {
    enable = lib.mkEnableOption "Enable new-api container";

    domain = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Domain name to serve new-api on via Caddy.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "Port for new-api to listen on.";
    };

    nodeName = lib.mkOption {
      type = lib.types.str;
      default = "new-api-node-1";
      description = "Node name for audit logs.";
    };

    redisPort = lib.mkOption {
      type = lib.types.port;
      default = 6380;
      description = "Redis port for new-api.";
    };
  };

  config = lib.mkIf cfg.enable {
    # PostgreSQL
    services.postgresql = {
      ensureDatabases = ["new-api"];
      ensureUsers = [
        {
          name = "new-api";
          ensureDBOwnership = true;
        }
      ];
    };

    # Redis
    services'.redis = {
      name = "new-api";
      port = cfg.redisPort;
    };

    sops.templates."new-api.env".content = ''
      REDIS_CONN_STRING=redis://:${config.sops.placeholder.redis_password}@127.0.0.1:${toString cfg.redisPort}
    '';

    systemd.tmpfiles.rules = [
      "d /var/lib/new-api 0755 root root -"
      "d /var/lib/new-api/data 0755 root root -"
      "d /var/lib/new-api/logs 0755 root root -"
    ];

    virtualisation.oci-containers.containers = {
      new-api = {
        hostname = "new-api";
        serviceName = "new-api";
        image = "calciumion/new-api:latest";
        environmentFiles = [
          config.sops.templates."new-api.env".path
        ];
        environment = {
          PORT = toString cfg.port;
          SQL_DSN = "postgresql://new-api@127.0.0.1:5432/new-api";
          TZ = "Asia/Shanghai";
          ERROR_LOG_ENABLED = "true";
          BATCH_UPDATE_ENABLED = "true";
          NODE_NAME = cfg.nodeName;
        };
        cmd = ["--log-dir" "/app/logs"];
        volumes = [
          "/var/lib/new-api/data:/data"
          "/var/lib/new-api/logs:/app/logs"
        ];
        extraOptions = [
          "--network=host"
          "--memory=512m"
          "--health-cmd"
          "wget -q -O - http://localhost:${toString cfg.port}/api/status | grep -o '\"success\":\\s*true' || exit 1"
          "--health-interval"
          "30s"
          "--health-timeout"
          "10s"
          "--health-retries"
          "3"
        ];
        autoStart = true;
      };
    };

    preservation'.os.directories = [
      "/var/lib/new-api"
    ];

    services.caddy.virtualHosts = lib.mkIf (cfg.domain != null) {
      "${cfg.domain}" = {
        extraConfig = ''
          encode zstd gzip
          reverse_proxy 127.0.0.1:${toString cfg.port}
        '';
      };
    };
  };
}
