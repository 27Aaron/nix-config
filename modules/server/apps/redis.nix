{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  cfg = config.services'.redis;
in {
  options.services'.redis = {
    enable = lib.mkEnableOption "Enable Redis service";

    name = lib.mkOption {
      type = lib.types.str;
      default = "redis";
      description = "Redis instance name";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 6379;
      description = "Redis port";
    };

    openFirewall = lib.mkEnableOption "Open firewall port for Redis";
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.redis_password = {
      sopsFile = "${inputs.my-secrets}/services/redis.yaml";
    };

    services.redis = {
      vmOverCommit = true;
      package = pkgs.valkey;
      servers.${cfg.name} = {
        enable = true;
        bind =
          if cfg.openFirewall
          then "0.0.0.0"
          else "127.0.0.1";
        port = cfg.port;
        logLevel = "notice";
        logfile = "\"\"";
        syslog = true;
        databases = 16;
        save = [
          [
            900
            1
          ]
          [
            300
            10
          ]
          [
            60
            10000
          ]
        ];
        requirePassFile = config.sops.secrets.redis_password.path;
        maxclients = 10000;
        appendOnly = true;
        appendFsync = "everysec";
        slowLogLogSlowerThan = 10000;
        slowLogMaxLen = 128;
        settings = {
          # Persistence
          dbfilename = "dump.rdb";
          appendfilename = "appendonly.aof";
          appenddirname = "appendonlydir";

          # Continue accepting writes when RDB snapshot fails
          stop-writes-on-bgsave-error = "no";

          # Memory management
          maxmemory = "256mb";
          maxmemory-policy = "allkeys-lru";

          # Modules
          enable-module-command = "local";
        };
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    systemd.tmpfiles.rules = [
      "d /var/lib/redis-${cfg.name} 0700 redis-${cfg.name} redis-${cfg.name} -"
    ];

    preservation'.os.directories = [
      "/var/lib/redis-${cfg.name}"
    ];
  };
}
