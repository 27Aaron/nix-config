{
  config,
  lib,
  ...
}: let
  cfg = config.services'.coder;

  # The upstream option is a "host:port" string, including IPv6 forms like
  # "[::]:3000"; the port is always the segment after the last colon.
  listenPort = lib.toInt (lib.last (lib.splitString ":" cfg.listenAddress));

  loopbackListen =
    lib.hasPrefix "127." cfg.listenAddress
    || lib.hasPrefix "localhost" cfg.listenAddress
    || lib.hasPrefix "[::1]" cfg.listenAddress;
in {
  options.services'.coder = {
    enable = lib.mkEnableOption "Enable Coder server";

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1:3000";
      description = "Address and port the Coder server listens on; use 0.0.0.0:3000 for direct LAN access";
    };

    accessUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "https://coder.example.com";
      description = "External URL users use to reach Coder; required for workspace apps and port forwarding";
    };

    wildcardAccessUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "*.coder.example.com";
      description = "Wildcard domain serving workspace apps";
    };

    database = {
      createLocally = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Use the local PostgreSQL managed by services'.postgresql; set false together with host below for a remote one";
      };

      host = lib.mkOption {
        type = lib.types.str;
        default = "/run/postgresql";
        description = "PostgreSQL host; a value starting with / is a Unix socket directory";
      };

      database = lib.mkOption {
        type = lib.types.str;
        default = "coder";
        description = "PostgreSQL database name";
      };

      username = lib.mkOption {
        type = lib.types.str;
        default = "coder";
        description = "PostgreSQL user; must stay coder while createLocally is enabled";
      };

      password = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "PostgreSQL password; ends up in the systemd unit environment in plaintext because the upstream module always sets the connection URL directly";
      };

      sslmode = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "disable";
        example = "require";
        description = "PostgreSQL SSL mode; use require or stricter when connecting over TCP to a remote database";
      };
    };

    openFirewall = lib.mkEnableOption "Open firewall port for Coder";
  };

  config = lib.mkIf cfg.enable {
    # Low-priority passthrough so hosts can still set the underlying
    # services.coder options directly without merge conflicts.
    services.coder = {
      enable = true;
      listenAddress = lib.mkDefault cfg.listenAddress;
      accessUrl = lib.mkDefault cfg.accessUrl;
      wildcardAccessUrl = lib.mkDefault cfg.wildcardAccessUrl;

      database = {
        createLocally = lib.mkDefault cfg.database.createLocally;
        host = lib.mkDefault cfg.database.host;
        database = lib.mkDefault cfg.database.database;
        username = lib.mkDefault cfg.database.username;
        password = lib.mkDefault cfg.database.password;
        sslmode = lib.mkDefault cfg.database.sslmode;
      };
    };

    # Catch a crash-looping misconfiguration at eval time: with the local
    # database, the socket directory is fixed by the PostgreSQL module.
    assertions = [
      {
        assertion = cfg.database.createLocally -> cfg.database.host == "/run/postgresql";
        message = "services'.coder.database.host must stay \"/run/postgresql\" while createLocally is enabled";
      }
    ];

    warnings =
      lib.optional
      (cfg.openFirewall && loopbackListen)
      "services'.coder.openFirewall is set but listenAddress ${cfg.listenAddress} is loopback-only; external clients still cannot reach Coder";

    # Reuse the repo's PostgreSQL module so its tuning, authentication map
    # and /var/lib/postgresql persistence apply whenever Coder needs a local
    # database. Hosts can still override it.
    services'.postgresql.enable = lib.mkDefault cfg.database.createLocally;

    # The upstream unit only orders after network.target, which races with
    # PostgreSQL init on first boot.
    systemd.services.coder.after = lib.mkIf cfg.database.createLocally ["postgresql.service"];

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [listenPort];

    # Upstream user/group/homeDir must stay at their defaults ("coder",
    # /var/lib/coder) for this ownership and directory to match.
    preservation'.os.directories = [
      {
        directory = "/var/lib/coder";
        user = "coder";
        group = "coder";
      }
    ];
  };
}
