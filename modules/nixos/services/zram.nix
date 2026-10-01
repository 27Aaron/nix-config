{ config, lib, ... }:
let
  cfg = config.services'.zram;
in
{
  options.services'.zram.enable = lib.mkEnableOption "compressed RAM swap with zram";

  config = lib.mkIf cfg.enable {
    boot = {
      kernelParams = [ "zswap.enabled=0" ];
      kernel.sysctl."vm.swappiness" = 100;
      kernel.sysfs.module.zswap.parameters.enabled = false;
    };

    zramSwap = {
      enable = true;
      priority = 100;
    };
  };
}
