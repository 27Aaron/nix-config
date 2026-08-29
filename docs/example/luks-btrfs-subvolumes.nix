{...}: {
  disko.devices = {
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "mode=755"
        "nodev"
        "nosuid"
        "relatime"
        "size=4G"
      ];
    };

    disk.main = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-CT1000P3PSSD8_24364AD5D8E0";

      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            size = "1G";
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

          luks = {
            priority = 2;
            size = "100%";
            type = "8309";
            content = {
              type = "luks";
              name = "crypted";
              askPassword = true;
              initrdUnlock = true;
              settings = {
                allowDiscards = true;
                bypassWorkqueues = true;
                crypttabExtraOpts = [
                  "same-cpu-crypt"
                  "submit-from-crypt-cpus"
                  "token-timeout=10"
                ];
              };
              extraFormatArgs = [
                "--type"
                "luks2"
                "--pbkdf"
                "argon2id"
              ];

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

                  "@swap" = {
                    mountpoint = "/swap";
                    swap.swapfile.size = "32769M";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
