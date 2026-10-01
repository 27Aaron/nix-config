{ ... }:
{
  security'.firewall.enable = true;

  services' = {
    avahi.enable = true;
    btrfs-scrub.enable = true;
    btrbk.enable = true;
    fail2ban.enable = true;
    gnome-keyring.enable = true;
    networkmanager.enable = true;
    openssh.enable = true;
    pipewire.enable = true;
    power-profiles-daemon.enable = true;
    smartd.enable = true;
    upower.enable = true;
    vnstat.enable = true;
    zram.enable = true;
  };

  system.stateVersion = "26.05";
}
