{
  config,
  lib,
  myvars,
  pkgs,
  ...
}: let
  cfg = config.services'.postgresql;
  user = myvars.username;
  remoteAuthentication =
    lib.concatMapStringsSep "\n" (
      cidr: "host    sameuser        all             ${cidr}               scram-sha-256"
    )
    cfg.allowedCIDRs;
in {
  options.services'.postgresql = {
    enable = lib.mkEnableOption "PostgreSQL service";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.postgresql_18;
      description = "PostgreSQL package to use";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/postgresql";
      description = "PostgreSQL data directory; changing the major version requires an explicit data migration";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 5432;
      description = "TCP port used by PostgreSQL";
    };

    allowedCIDRs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = ["192.168.1.0/24"];
      description = "Network CIDRs allowed to authenticate remotely when openFirewall is enabled";
    };

    openFirewall = lib.mkEnableOption "Open firewall port for PostgreSQL";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.openFirewall || cfg.allowedCIDRs != [];
        message = "services'.postgresql.allowedCIDRs must not be empty when openFirewall is enabled";
      }
    ];

    services.postgresql = {
      enable = true;
      inherit (cfg) package dataDir;
      enableJIT = true;
      enableTCPIP = cfg.openFirewall;

      settings = {
        port = cfg.port;
        max_connections = 100;
        log_connections = true;
        log_statement = "ddl";
        log_disconnections = true;
        shared_buffers = "128MB";
        huge_pages = "try";
      };

      identMap = ''
        superuser_map      root                postgres
        superuser_map      postgres            postgres
        superuser_map      postgres-exporter   postgres
        superuser_map      ${user}             postgres
        # Let other names login as themselves
        superuser_map      /^(.*)$             \1
      '';

      initdbArgs = [
        "--data-checksums"
        "--allow-group-access"
      ];

      # https://www.postgresql.org/docs/current/auth-pg-hba-conf.html
      authentication = ''
        # TYPE  DATABASE        USER            ADDRESS                 METHOD   OPTIONS

        # "local" is for Unix domain socket connections only
        local   all             all                                     peer     map=superuser_map
        # IPv4 local connections:
        host    all             all             127.0.0.1/32            scram-sha-256
        # IPv6 local connections:
        host    all             all             ::1/128                 scram-sha-256

        # Replication connections from localhost still require OS identity or
        # a PostgreSQL password.
        local   replication     all                                     peer     map=superuser_map
        host    replication     all             127.0.0.1/32            scram-sha-256
        host    replication     all             ::1/128                 scram-sha-256

        # Remote access is opt-in per source network and only permits a
        # database with the same name as the authenticated user.
        ${remoteAuthentication}
      '';
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    preservation'.os.directories = [
      {
        directory = cfg.dataDir;
        user = "postgres";
        group = "postgres";
        mode = "0750";
      }
    ];
  };
}
