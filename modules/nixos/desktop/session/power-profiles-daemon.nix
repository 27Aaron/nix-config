{
  config,
  lib,
  ...
}: let
  cfg = config.services'.power-profiles-daemon;
in {
  options.services'.power-profiles-daemon = {
    enable = lib.mkEnableOption "Power profiles management daemon";
  };

  config = {
    services.power-profiles-daemon.enable = lib.mkIf cfg.enable true;

    # Upstream consumers may enable this daemon on their own, so persistence
    # follows the final service state, whoever turned it on.
    preservation'.os.directories = lib.optionals config.services.power-profiles-daemon.enable [
      # Power management
      "/var/lib/power-profiles-daemon"
    ];
  };
}
