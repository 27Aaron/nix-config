{
  config,
  lib,
  ...
}:
let
  cfg = config.services'.upower;
in
{
  options.services'.upower = {
    enable = lib.mkEnableOption "UPower power management daemon";
  };

  config = {
    services.upower.enable = lib.mkIf cfg.enable true;

    # Upstream consumers may enable this daemon on their own, so persistence
    # follows the final service state, whoever turned it on.
    preservation'.os.directories = lib.optionals config.services.upower.enable [
      "/var/lib/upower"
    ];
  };
}
