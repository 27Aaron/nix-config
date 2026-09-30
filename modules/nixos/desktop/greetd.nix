{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.desktop'.greetd;
in
{
  options.desktop'.greetd = {
    enable = lib.mkEnableOption "Greetd login manager with Tuigreet";
  };

  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      useTextGreeter = true;
      settings.default_session.command = "${lib.getExe pkgs.tuigreet} --remember --time --sessions /run/current-system/sw/share/wayland-sessions";
    };

    preservation'.os.directories = [
      {
        directory = "/var/cache/tuigreet";
        user = "greeter";
        group = "greeter";
      }
    ];
  };
}
