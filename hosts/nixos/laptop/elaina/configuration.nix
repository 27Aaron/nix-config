{ ... }:
{
  networking.networkmanager.enable = true;

  services = {
    btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
    };
    openssh.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
    power-profiles-daemon.enable = true;
    upower.enable = true;
  };

  zramSwap.enable = true;

  system.stateVersion = "26.05";
}
