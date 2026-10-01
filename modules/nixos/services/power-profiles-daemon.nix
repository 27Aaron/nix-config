{ config, lib, ... }:
let
  cfg = config.services'.power-profiles-daemon;
in
{
  options.services'.power-profiles-daemon = {
    enable = lib.mkEnableOption "power profiles management daemon";
  };

  config = {
    services.power-profiles-daemon.enable = lib.mkIf cfg.enable true;

    preservation.preserveAt."/persistent".directories =
      lib.mkIf (cfg.enable && config.hardware'.persistence.enable)
        [
          "/var/lib/power-profiles-daemon"
        ];
  };
}
