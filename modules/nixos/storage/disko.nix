{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.storage'.disko;

  btrfsSubvolumes =
    {
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
    }
    // lib.optionalAttrs (cfg.swapSize != null) {
      "@swap" = {
        mountpoint = "/swap";
        swap.swapfile.size = cfg.swapSize;
      };
    };
in {
  imports = [inputs.disko.nixosModules.disko];

  options.storage'.disko = {
    enable = lib.mkEnableOption "Disko disk management";

    device = lib.mkOption {
      type = lib.types.str;
      example = "/dev/disk/by-id/nvme-example";
      description = "Disk device path";
    };

    tmpfsSize = lib.mkOption {
      type = lib.types.str;
      default = "4G";
      example = "512M";
      description = "Tmpfs root size";
    };

    espSize = lib.mkOption {
      type = lib.types.str;
      default = "256M";
      example = "1G";
      description = "EFI system partition size";
    };

    swapSize = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "8G";
      description = "Btrfs swap file size, or null to disable swap";
    };

    luks.enable = lib.mkEnableOption "LUKS encryption";
  };

  config = lib.mkIf cfg.enable {
    disko.devices = {
      nodev."/" = {
        fsType = "tmpfs";
        mountOptions = [
          "mode=755"
          "nodev"
          "nosuid"
          "relatime"
          "size=${cfg.tmpfsSize}"
        ];
      };

      disk.main = {
        type = "disk";
        device = cfg.device;
        content = {
          type = "gpt";
          partitions =
            {
              ESP = {
                priority = 1;
                size = cfg.espSize;
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
            }
            // (
              if cfg.luks.enable
              then {
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
                      subvolumes = btrfsSubvolumes;
                    };
                  };
                };
              }
              else {
                root = {
                  priority = 2;
                  size = "100%";
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
                    subvolumes = btrfsSubvolumes;
                  };
                };
              }
            );
        };
      };
    };
  };
}
