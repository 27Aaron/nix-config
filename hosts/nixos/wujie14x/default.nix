# Wujie14x - MECHREVO WUJIE14XA laptop (Ryzen 7 8845HS, 32 GB DDR5, 1 TB NVMe)
#
# A full desktop laptop: greetd autologin into Niri with the Noctalia shell,
# plus PipeWire, fcitx5, fonts and themes, on top of the networking, power
# management and remote administration base.
{ ... }:
{
  imports = [
    ./hardware.nix
  ];

  services' = {
    btrfs-scrub.enable = true;
    gnome-keyring.enable = true;
    networkmanager.enable = true;
    openssh.enable = true;
    pipewire.enable = true;
    power-profiles-daemon.enable = true;
    smartd.enable = true;
    upower.enable = true;
    zram.enable = true;
  };

  desktop' = {
    applications.enable = true;
    mime-apps.enable = true;
    apps = {
      firefox.enable = true;
      kitty.enable = true;
      zed.enable = true;
    };
    cursors.enable = true;
    fcitx5.enable = true;
    fonts.enable = true;
    greetd.enable = true;
    niri.autoLogin = true;
    niri.enable = true;
    noctalia.enable = true;
    themes.enable = true;
    xdg-user-dirs.enable = true;
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
