{
  config,
  lib,
  pkgs,
  username,
  ...
}:
let
  cfg = config.desktop'.greetd;
  sessionArgs = lib.optionalString (cfg.sessionCommand != null) " --cmd ${cfg.sessionCommand}";
in
{
  options.desktop'.greetd = {
    enable = lib.mkEnableOption "Greetd login manager with Tuigreet";
    sessionCommand = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Session command launched by Tuigreet.";
    };
    autoLogin = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to start the configured session without a greeter.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.autoLogin || cfg.sessionCommand != null;
        message = "desktop'.greetd.autoLogin requires a sessionCommand";
      }
    ];

    services.greetd = {
      enable = true;
      settings = {
        default_session.command = "${lib.getExe pkgs.tuigreet} --time${sessionArgs}";
        initial_session = lib.mkIf cfg.autoLogin {
          command = cfg.sessionCommand;
          user = username;
        };
      };
    };
  };
}
