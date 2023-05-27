{
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.hardware'.disko;
in {
  imports = [inputs.disko.nixosModules.disko];

  options.hardware'.disko = {
    enable = lib.mkEnableOption "enable disko disk management";

    device = lib.mkOption {
      type = lib.types.str;
      example = "/dev/vda";
      description = "Disk device path";
    };
  };

  config = lib.mkIf cfg.enable {
    fileSystems."/persistent".neededForBoot = true;

    disko.devices = {
      nodev = {
        "/" = {
          fsType = "tmpfs";
          mountOptions = [
            "nodev"
            "nosuid"
            "relatime"
            "mode=755"
            "size=500M"
          ];
        };
      };

      disk = {
        main = {
          type = "disk";
          device = cfg.device;
          content = {
            type = "gpt";
            partitions = {
              boot = {
                size = "1M";
                type = "EF02";
                priority = 0;
              };
              esp = {
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
              nix = {
                size = "100%";
                content = {
                  type = "btrfs";
                  extraArgs = [
                    "-f"
                    "--csum xxhash64"
                    "--label NixOS"
                  ];
                  # Override existing partition
                  subvolumes = {
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "@persistent" = {
                      mountpoint = "/persistent";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "@tmp" = {
                      mountpoint = "/tmp";
                      mountOptions = [
                        "compress=zstd"
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
    };
  };
}
