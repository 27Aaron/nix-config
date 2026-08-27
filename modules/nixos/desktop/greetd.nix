{
  config,
  lib,
  ...
}: let
  cfg = config.desktop'.greetd;
in {
  options.desktop'.greetd = {
    enable = lib.mkEnableOption "Greetd login manager with Tuigreet";
  };

  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      useTextGreeter = true;
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
