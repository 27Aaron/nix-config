{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  cfg = config.services'.mimotion;
in {
  imports = [
    inputs.mimotion.nixosModules.default
  ];

  options.services'.mimotion = {
    enable = lib.mkEnableOption "MiMotion auto step counter service";

    domain = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Domain for Caddy reverse proxy.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.mimotion.enable = true;

    services.caddy.virtualHosts = lib.mkIf (cfg.domain != null) {
      "${cfg.domain}".extraConfig = ''
        reverse_proxy localhost:${toString config.services.mimotion.port}
      '';
    };

    preservation'.os.directories = [
      {
        directory = config.services.mimotion.dataDir;
        inherit (config.services.mimotion) user group;
      }
    ];
  };
}
