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
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkgs.xwayland-satellite];

    programs.niri = {
      enable = true;
      package = pkgs.niri;
    };

    # Autologin into Niri through the machine's greeter.
    services.greetd.settings = {
      initial_session = {
        command = niriSession;
        user = myvars.username;
      };
      default_session.command = "${lib.getExe pkgs.tuigreet} --remember --time --cmd ${niriSession}";
    };

    preservation'.user.directories = [
      # Niri
      ".config/niri"
    ];
  };
}
