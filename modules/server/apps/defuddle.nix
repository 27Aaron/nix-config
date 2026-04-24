{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  cfg = config.services'.defuddle;
in {
  imports = [
    inputs.defuddle.nixosModules.default
  ];

  options.services'.defuddle = {
    enable = lib.mkEnableOption "Defuddle Proxy self-hosted parsing proxy service";

    domain = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Domain for Caddy reverse proxy.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.defuddle-proxy.enable = true;

    services.caddy.virtualHosts = lib.mkIf (cfg.domain != null) {
      "${cfg.domain}".extraConfig = ''
        reverse_proxy localhost:${toString config.services.defuddle-proxy.port}
      '';
    };

    preservation'.os.directories = [
      {
        directory = config.services.defuddle-proxy.dataDir;
        inherit (config.services.defuddle-proxy) user group;
      }
    ];
  };
}
