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
      default = "monthly";
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
