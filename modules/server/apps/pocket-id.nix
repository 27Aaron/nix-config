{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  cfg = config.services'.pocket-id;
  inherit (config.services.pocket-id) user group;
in {
  options.services'.pocket-id = {
    enable = lib.mkEnableOption "Enable pocket-id server";

    domain = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "The domain name for Pocket-ID";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services'.postgresql.enable;
        message = "services'.pocket-id requires services'.postgresql to be enabled";
      }
      {
        assertion = cfg.domain == null || config.services'.caddy.enable;
        message = "services'.pocket-id requires services'.caddy to be enabled when domain is set";
      }
    ];

    sops.secrets = {
      pocket-id_key = {
        sopsFile = "${inputs.my-secrets}/services/pocket-id.yaml";
        owner = config.services.pocket-id.user;
        group = config.services.pocket-id.group;
      };
    };

    services.pocket-id = {
      enable = true;
      settings = {
        APP_URL = "https://${cfg.domain}";
        TRUST_PROXY = true;
        ENCRYPTION_KEY_FILE = config.sops.secrets.pocket-id_key.path;
        PUID = config.users.users.pocket-id.uid;
        PGID = config.users.groups.pocket-id.gid;
        DB_CONNECTION_STRING = "postgres://${user}?host=/run/postgresql&user=${user}";
        HOST = "127.0.0.1";

        UI_CONFIG_DISABLED = false;
        APP_NAME = "Aaron's Auth Gateway";
      };
    };

    services.postgresql = {
      ensureDatabases = [user];
      ensureUsers = [
        {
          name = user;
          ensureDBOwnership = true;
        }
      ];
    };

    services.caddy.virtualHosts = lib.mkIf (cfg.domain != null) {
      "${cfg.domain}" = {
        extraConfig = ''
          reverse_proxy localhost:1411 {
            import cloudflare_headers
          }
        '';
      };
    };

    # Create data directory and ensure it exists
    systemd.tmpfiles.rules = [
      "d ${config.services.pocket-id.dataDir}/data 0755 ${user} ${group} -"
    ];

    # Service to download GeoLite2 database if it doesn't exist
    systemd.services.pocket-id-geolite = {
      description = "Download GeoLite2 database for Pocket-ID";
      wantedBy = [
        "multi-user.target"
        "pocket-id.service"
      ];
      after = ["network.target"];
      before = ["pocket-id.service"];
      serviceConfig = {
        Type = "oneshot";
        User = user;
        Group = group;
        ExecStart = "${pkgs.bash}/bin/bash -c 'if [ ! -f \"${config.services.pocket-id.dataDir}/data/GeoLite2-City.mmdb\" ]; then echo \"Downloading GeoLite2-City.mmdb...\"; ${pkgs.curl}/bin/curl -L -o \"${config.services.pocket-id.dataDir}/data/GeoLite2-City.mmdb\" \"https://git.io/GeoLite2-City.mmdb\"; echo \"GeoLite2-City.mmdb downloaded successfully\"; else echo \"GeoLite2-City.mmdb already exists, skipping download\"; fi'";
      };
    };

    preservation'.os.directories = [
      {
        directory = config.services.pocket-id.dataDir;
        inherit (config.services.pocket-id) user group;
      }
    ];
  };
}
