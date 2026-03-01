{
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.hardware'.disko-luks;
in
{
  imports = [ inputs.disko.nixosModules.disko ];

  options.hardware'.disko-luks = {
    enable = lib.mkEnableOption "Enable LUKS encrypted disk";

    device = lib.mkOption {
      type = lib.types.str;
      example = "/dev/nvme0n1";
      description = "Disk device path";
    };

    swapSize = lib.mkOption {
      type = lib.types.str;
      default = "8192M";
      example = "16384M";
      description = "Swap partition size";
    };
  };

  config = lib.mkIf cfg.enable {
    boot.tmp.useTmpfs = true;
    boot.tmp.cleanOnBoot = true;

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
          device = cfg.device;
          content = {
            type = "gpt";
            partitions = {
              esp = {
                priority = 0;
                size = "2G";
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
              encryptedSwap = {
                priority = 1;
                size = cfg.swapSize;
                content = {
                  type = "swap";
                  randomEncryption = true;
                };
              };
              crypted = {
                priority = 2;
                size = "100%";
                content = {
                  type = "luks";
                  name = "crypted";
                  settings = {
                    allowDiscards = true;
                    bypassWorkqueues = true;
                    crypttabExtraOpts = [
                      "same-cpu-crypt"
                      "submit-from-crypt-cpus"
                    ];
                  };
                  content = {
                    type = "btrfs";
                    extraArgs = [
                      "-f"
                      "--label nixos"
                      "--csum xxhash64"
                      "--features"
                      "block-group-tree"
                    ];
                    subvolumes = {
                      "persistent" = {
                        mountpoint = "/persistent";
                        mountOptions = [
                          "compress-force=zstd"
                          "noatime"
                          "discard=async"
                          "space_cache=v2"
                        ];
                      };
                      "nix" = {
                        mountpoint = "/nix";
                        mountOptions = [
                          "compress-force=zstd"
                          "noatime"
                          "discard=async"
                          "space_cache=v2"
                          "nodev"
                          "nosuid"
                        ];
                      };
                      "persistent/tmp" = {
                        mountpoint = "/tmp";
                        mountOptions = [
                          "relatime"
                          "nodev"
                          "nosuid"
                          "discard=async"
                          "space_cache=v2"
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
  };
}
