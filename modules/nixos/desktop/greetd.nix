{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.desktop'.greetd;
in {
  options.desktop'.greetd = {
    enable = lib.mkEnableOption "Greetd login manager with Tuigreet";

    sessionCommand = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "niri-session";
      description = ''
        Session command Tuigreet launches after login. Null keeps the
        greeter default. Set by the desktop module that owns the session,
        so the greeter binary choice stays inside this module.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      useTextGreeter = true;
      settings.default_session.command = lib.mkIf (cfg.sessionCommand != null) "${lib.getExe pkgs.tuigreet} --remember --time --cmd ${cfg.sessionCommand}";
    };

    preservation'.os.directories = [
      # Tuigreet
      {
        directory = "/var/cache/tuigreet";
        user = "greeter";
        group = "greeter";
      }
    ];
  };
}
