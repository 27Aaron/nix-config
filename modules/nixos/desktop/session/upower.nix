{
  config,
  lib,
  ...
}: let
  cfg = config.services'.upower;
in {
  options.services'.upower = {
    enable = lib.mkEnableOption "UPower power management daemon";
  };

  config = lib.mkIf cfg.enable {
    services.upower.enable = true;

    preservation'.os.directories = [
      "/var/lib/upower"
    ];
  };
}
