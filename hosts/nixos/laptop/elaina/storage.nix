let
  disk = "/dev/disk/by-id/nvme-CT1000P3PSSD8_24364AD5D8E0";
  crypt = "/dev/mapper/crypted";
  btrfsOptions = [
    "compress=zstd:1"
    "discard=async"
    "noatime"
  ];
in
{
  # Match the existing layout from the previous elaina installation.
  boot.initrd.luks.devices.crypted = {
    device = "${disk}-part2";
    allowDiscards = true;
  };

  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };

  fileSystems = {
    "/" = {
      device = crypt;
      fsType = "btrfs";
      options = [ "subvol=@persistent" ] ++ btrfsOptions;
    };

    "/boot" = {
      device = "${disk}-part1";
      fsType = "vfat";
      options = [ "umask=0077" ];
    };

    "/nix" = {
      device = crypt;
      fsType = "btrfs";
      options = [ "subvol=@nix" ] ++ btrfsOptions;
    };

    "/snapshots" = {
      device = crypt;
      fsType = "btrfs";
      options = [ "subvol=@snapshots" ] ++ btrfsOptions;
    };

    "/swap" = {
      device = crypt;
      fsType = "btrfs";
      options = [ "subvol=@swap" ] ++ btrfsOptions;
      neededForBoot = true;
    };
  };

  swapDevices = [ { device = "/swap/swapfile"; } ];
}
