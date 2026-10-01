{ config, lib, ... }:
let
  cfg = config.services'.upower;
in
{
  options.services'.upower.enable = lib.mkEnableOption "UPower power management daemon";

  config = {
    services.upower.enable = lib.mkIf cfg.enable true;

    preservation.preserveAt."/persistent".directories =
      lib.mkIf (cfg.enable && config.hardware'.persistence.enable)
        [
          "/var/lib/upower"
        ];
  };
}
