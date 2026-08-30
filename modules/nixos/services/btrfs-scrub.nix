{
  config,
  lib,
  ...
}: let
  cfg = config.services'.btrfs-scrub;
in {
  options.services'.btrfs-scrub = {
    enable = lib.mkEnableOption "monthly Btrfs data scrubbing";

    interval = lib.mkOption {
      type = lib.types.str;
      # First day of the month at 04:00, away from the 00:00/12:00 snapshot
      # slots of btrbk so the long scrub does not overlap with backups.
      default = "*-*-01 04:00:00";
      description = "Systemd calendar expression controlling scrub frequency";
    };
  };

  config = lib.mkIf cfg.enable {
    services.btrfs.autoScrub = {
      enable = true;
      inherit (cfg) interval;
    };
  };
}
