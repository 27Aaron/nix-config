{
  # required by impermanence
  fileSystems."/persistent".neededForBoot = true;

  disko.devices = {
    nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [
          "relatime"
          "nosuid"
          "nodev"
          "size=4G"
          "mode=755"
        ];
      };
    };

    disk = {
      nvme = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                extraArgs = [
                  "-n"
                  "BOOT"
                ];
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            # The root partition
            luks = {
              size = "100%";
              type = "8309";
              content = {
                type = "luks";
                name = "crypted";
                settings = {
                  keyFile = "/dev/disk/by-label/LUKS_KEY"; # The keyfile is stored on a USB stick
                  # The maximum size of the keyfile is 8192 KiB
                  # type `cryptsetup --help` to see the compiled-in key and passphrase maximum sizes
                  keyFileSize = 512 * 64; # match the `bs * count` of the `dd` command
                  keyFileOffset = 512 * 128; # match the `bs * skip` of the `dd` command
                  fallbackToPassword = true;
                  allowDiscards = true;
                };

                # Whether to add a boot.initrd.luks.devices entry for the specified disk.
                initrdUnlock = true;

                # encrypt the root partition with luks2 and argon2id, will prompt for a passphrase, which will be used to unlock the partition.
                # cryptsetup luksFormat
                extraFormatArgs = [
                  "--type luks2"
                  "--cipher aes-xts-plain64"
                  "--hash sha512"
                  "--iter-time 5000"
                  "--key-size 256"
                  "--pbkdf argon2id"
                  # use true random data from /dev/random, will block until enough entropy is available
                  "--use-random"
                ];

                content = {
                  type = "btrfs";
                  extraArgs = [
                    "-f"
                    "--csum xxhash64"
                    "--label NixOS"
                  ]; # Override existing partition
                  subvolumes = {
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "compress-force=zstd:1"
                        "noatime"
                        "discard=async"
                        "space_cache=v2"
                        "nodev"
                        "nosuid"
                      ];
                    };
                    "@persistent" = {
                      mountpoint = "/persistent";
                      mountOptions = [
                        "compress-force=zstd:1"
                        "noatime"
                        "discard=async"
                        "space_cache=v2"
                      ];
                    };
                    "@tmp" = {
                      mountpoint = "/tmp";
                      mountOptions = [
                        "noatime"
                        "discard=async"
                        "space_cache=v2"
                        "nodev"
                        "nosuid"
                      ];
                    };
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
