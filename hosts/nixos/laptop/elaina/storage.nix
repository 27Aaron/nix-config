{
  nixos.disko = {
    enable = true;
    device = "/dev/disk/by-id/nvme-CT1000P3PSSD8_24364AD5D8E0";
    espSize = "1G";
    swapSize = "32G";
    luks.enable = true;
  };

  nixos.persistence.enable = true;
  nixos.boot.systemd-boot.enable = true;
}
