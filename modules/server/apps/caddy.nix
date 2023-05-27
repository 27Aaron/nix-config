{
  lib,
  config,
  ...
}: let
  cfg = config.services'.caddy;
in {
  options.services'.caddy = {
    enable = lib.mkEnableOption "Enable Caddy web server";

    accessLog = {
      rollSize = lib.mkOption {
        type = lib.types.str;
        default = "20MiB";
        description = "Maximum size of each Caddy access log file before rotation.";
      };

      keep = lib.mkOption {
        type = lib.types.int;
        default = 10;
        description = "How many rotated Caddy access log files to keep per virtual host.";
      };

      keepFor = lib.mkOption {
        type = lib.types.str;
        default = "168h";
        description = "How long rotated Caddy access log files are kept.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.caddy = {
      enable = true;
      enableReload = true;
      adapter = "caddyfile";
      user = "caddy";
      logDir = "/var/log/caddy";
      logFormat = lib.mkForce ''
        level INFO
        format console
      '';
      extraConfig = lib.mkBefore ''
        (cloudflare_headers) {
        header_up X-Real-IP {http.request.header.CF-Connecting-IP}
        header_up X-Forwarded-For {http.request.header.CF-Connecting-IP}
        }
        (default_access_log) {
        log {
          output file ${config.services.caddy.logDir}/access.log {
            roll_size ${cfg.accessLog.rollSize}
            roll_keep ${toString cfg.accessLog.keep}
            roll_keep_for ${cfg.accessLog.keepFor}
          }
          format console
        }
        }
      '';
    };

    networking.firewall = {
      allowedTCPPorts = [
        80
        443
      ];
      allowedUDPPorts = [443];
    };

    preservation'.os.directories = [
      {
        directory = config.services.caddy.dataDir;
        inherit (config.services.caddy) user group;
      }
    ];
  };
}
