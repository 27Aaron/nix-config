{...}: {
  disko.devices = {
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "mode=755"
        "nodev"
        "nosuid"
        "relatime"
        "size=512M"
      ];
    };

    disk.main = {
      type = "disk";
      device = "/dev/sda";

      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            size = "256M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              extraArgs = [
                "-n"
                "BOOT"
              ];
              mountOptions = ["umask=0077"];
            };
          };

          root = {
            priority = 2;
            size = "100%";
            type = "8300";
            content = {
              type = "btrfs";
              extraArgs = [
                "-f"
                "--csum"
                "xxhash64"
                "--label"
                "NixOS"
              ];
              mountpoint = "/btr_pool";
              mountOptions = [
                "noatime"
                "subvolid=5"
              ];

              subvolumes = {
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress=zstd:1"
                    "discard=async"
                    "noatime"
                  ];
                };

                "@persistent" = {
                  mountpoint = "/persistent";
                  mountOptions = [
                    "compress=zstd:1"
                    "discard=async"
                    "noatime"
                  ];
                };

                "@snapshots" = {
                  mountpoint = "/snapshots";
                  mountOptions = [
                    "compress=zstd:1"
                    "discard=async"
                    "noatime"
                  ];
                };
              };
            };
          };
        };
      };
    };
  };
}
