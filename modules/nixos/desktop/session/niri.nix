{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.desktop'.niri;
  niriSession = lib.getExe' pkgs.niri "niri-session";
in
{
  options.desktop'.niri = {
    enable = lib.mkEnableOption "Niri desktop environment";
    autoLogin = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to log in to the Niri session automatically.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.autoLogin || config.desktop'.greetd.enable;
        message = "desktop'.niri.autoLogin requires desktop'.greetd.enable";
      }
    ];

    programs.niri.enable = true;
    environment.systemPackages = [ pkgs.xwayland-satellite ];

    desktop'.greetd = {
      sessionCommand = lib.mkIf config.desktop'.greetd.enable niriSession;
      autoLogin = lib.mkIf config.desktop'.greetd.enable cfg.autoLogin;
    };
  };
}
