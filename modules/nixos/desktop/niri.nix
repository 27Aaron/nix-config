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

    programs.niri.enable = true;

    # Register the session with greetd when it drives the login screen; the
    # greeter command itself is assembled by the greetd module.
    desktop'.greetd.sessionCommand = lib.mkIf config.desktop'.greetd.enable niriSession;

    services.greetd.settings = lib.mkIf (cfg.autoLogin && config.desktop'.greetd.enable) {
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
