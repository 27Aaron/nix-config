{ ... }:
{
  services' = {
    btrfs-scrub.enable = true;
    networkmanager.enable = true;
    openssh.enable = true;
    pipewire.enable = true;
    power-profiles-daemon.enable = true;
    upower.enable = true;
    zram.enable = true;
  };

  system.stateVersion = "26.05";
}
