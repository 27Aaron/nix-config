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
    networkmanager.enable = true;
    openssh.enable = true;
    power-profiles-daemon.enable = true;
    upower.enable = true;
    zram.enable = true;
  };

  core'.firewall.enable = true;
  core'.kernel-hardening.enable = true;

  # Lid behaviour. s2idle is the only suspend mode this platform has (the BIOS
  # exposes no S3), and systemd already defaults to "suspend" for the lid, so
  # these are written out to make the intent explicit:
  #   - suspend when the lid closes, on battery and on AC alike;
  #   - stay awake while docked, so the internal panel can be shut on a desk
  #     with an external display attached.
  # The spurious-wakeup fix that makes this actually hold is the
  # `acpi.ec_no_wakeup=1` kernel parameter in hardware.nix.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
  };

  # Remote deployment via colmena.
  deployment.tags = [ "laptop" ];

  system.stateVersion = "26.05";
}
