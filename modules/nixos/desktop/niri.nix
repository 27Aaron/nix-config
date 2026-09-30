{
  config,
  lib,
  myvars,
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
      description = "Whether to log in to the Niri session automatically, skipping the greeter";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.xwayland-satellite ];

    programs.niri.enable = true;

    services.greetd.settings.initial_session = lib.mkIf cfg.autoLogin {
      command = niriSession;
      user = myvars.username;
    };

    preservation'.user.directories = [ ".config/niri" ];
  };
}
