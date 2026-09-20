{
  config,
  lib,
  ...
}:
let
  cfg = config.services'.zram;
in
{
  options.services'.zram = {
    enable = lib.mkEnableOption "compressed RAM swap with Zram";
  };

  config = lib.mkIf cfg.enable {
    # Most kernels enable zswap by default (the NixOS default kernel is a
    # notable exception). Disable it to avoid putting a compressed cache in
    # front of the compressed Zram swap device.
    boot = {
      kernelParams = [ "zswap.enabled=0" ];
      kernel.sysctl."vm.swappiness" = 100;
      kernel.sysfs.module.zswap.parameters.enabled = false;
    };

    zramSwap = {
      enable = true;
      # Keep the Zram device ahead of any disk-backed swap.
      priority = 100;
    };
  };
}
