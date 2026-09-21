# Wujie14x - MECHREVO WUJIE14XA laptop (Ryzen 7 8845HS, 32 GB DDR5, 1 TB NVMe)
#
# A headless-but-interactive laptop base: networking, power management and
# remote administration only. The desktop stack (greetd, niri, Noctalia,
# PipeWire, fonts, ...) is intentionally left off until it is actually wanted.
{ ... }:
{
  imports = [
    ./hardware.nix
  ];

  services' = {
    btrfs-scrub.enable = true;
    networkmanager.enable = true;
    openssh.enable = true;
    power-profiles-daemon.enable = true;
    smartd.enable = true;
    upower.enable = true;
    zram.enable = true;
  };

  core'.firewall.enable = true;
  core'.kernel-hardening.enable = true;

  # Lid behaviour. s2idle is the only suspend mode this platform has (the BIOS
  # exposes no S3), so the lid suspends first and, after an hour, hands over to
  # hibernate. On AC power the countdown never starts, so the machine simply
  # stays suspended; staying awake while docked keeps the internal panel usable
  # when an external display is attached.
  # The spurious-wakeup fix that makes this actually hold is the
  # `acpi.ec_no_wakeup=1` kernel parameter in hardware.nix.
  systemd.sleep.settings.Sleep = {
    AllowSuspendThenHibernate = "yes";
    HibernateDelaySec = "1h";
    HibernateOnACPower = "no";
  };

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend-then-hibernate";
    HandleLidSwitchDocked = "ignore";
  };

  # Remote deployment via colmena.
  deployment.tags = [ "laptop" ];

  system.stateVersion = "26.05";
}
