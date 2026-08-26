{
  config,
  lib,
  ...
}: let
  cfg = config.services'.btrfs-scrub;
in {
  options.services'.btrfs-scrub = {
    enable = lib.mkEnableOption "monthly Btrfs data scrubbing";
  };

  config = lib.mkIf cfg.enable {
    services.btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
    };
  };
}
