# Router services: intrusion prevention, traffic accounting and compressed
# swap.
{ ... }:
{
  services.fail2ban = {
    enable = true;
    bantime = "1h";
    bantime-increment = {
      enable = true;
      maxtime = "1w";
      rndtime = "10m";
    };
  };

  services.vnstat.enable = true;

  # Disable zswap (on by default in most kernels) so no compressed cache sits
  # in front of the compressed Zram swap device.
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

  # State of the long-running services above.
  preservation'.os.directories = [
    "/var/lib/fail2ban"
    {
      directory = "/var/lib/vnstat";
      user = "vnstatd";
      group = "vnstatd";
    }
  ];
}
