{
  config,
  lib,
  myvars,
  pkgs,
  ...
}: let
  cfg = config.desktop'.niri;
  niriSession = lib.getExe' pkgs.niri "niri-session";
in {
  options.desktop'.niri = {
    enable = lib.mkEnableOption "Niri desktop environment";
    autoLogin = lib.mkEnableOption "automatic login to the Niri session";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkgs.xwayland-satellite];

    programs.niri = {
      enable = true;
      package = pkgs.niri;
    };

    services.greetd.settings =
      {
        default_session.command = "${lib.getExe pkgs.tuigreet} --remember --time --cmd ${niriSession}";
      }
      // lib.optionalAttrs cfg.autoLogin {
        initial_session = {
          command = niriSession;
          user = myvars.username;
        };
      };

    preservation'.user.directories = [
      # Niri
      ".config/niri"
    ];
  };
}
