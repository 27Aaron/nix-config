{
  config,
  lib,
  ...
}: let
  cfg = config.services'.zram;
in {
  options.services'.zram = {
    enable = lib.mkEnableOption "compressed RAM swap with Zram";
  };

  config = lib.mkIf cfg.enable {
    # CachyOS enables zswap by default. Disable it to avoid putting a
    # compressed cache in front of the compressed Zram swap device.
    boot = {
      kernelParams = ["zswap.enabled=0"];
      kernel.sysctl."vm.swappiness" = 100;
      kernel.sysfs.module.zswap.parameters.enabled = false;
      zswap.enable = false;
    };

    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 50;
      memoryMax = 8 * 1024 * 1024 * 1024;
      priority = 100;
    };
  };
}
