{
  config,
  lib,
  myvars,
  pkgs,
  ...
}: let
  cfg = config.services'.postgresql;
  user = myvars.username;
in {
  options.services'.postgresql = {
    enable = lib.mkEnableOption "Enable PostgreSQL service";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.postgresql_18;
      description = "PostgreSQL package to use";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/postgresql";
      description = "Directory in which PostgreSQL stores its data";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 5432;
      description = "TCP port used by PostgreSQL";
    };

    openFirewall = lib.mkEnableOption "Open firewall port for PostgreSQL";
  };

  config = lib.mkIf cfg.enable {
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
        logging_collector = true;
        log_disconnections = true;
        log_destination = lib.mkForce "syslog";
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
      authentication = lib.mkForce ''
        # TYPE  DATABASE        USER            ADDRESS                 METHOD   OPTIONS

        # "local" is for Unix domain socket connections only
        local   all             all                                     peer     map=superuser_map
        # IPv4 local connections:
        host    all             all             127.0.0.1/32            trust
        # IPv6 local connections:
        host    all             all             ::1/128                 trust

        # Allow replication connections from localhost, by a user with the
        # replication privilege.
        local   replication     all                                     trust
        host    replication     all             127.0.0.1/32            trust
        host    replication     all             ::1/128                 trust

        # Other Remote Access - allow access only the database with the same name as the user
        host    sameuser        all             0.0.0.0/0               scram-sha-256
      '';
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    preservation'.os.directories = [cfg.dataDir];
  };
}
