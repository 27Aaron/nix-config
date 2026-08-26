{
  config,
  lib,
  ...
}: let
  cfg = config.services'.btrbk;
in {
  options.services'.btrbk = {
    enable = lib.mkEnableOption "local Btrfs snapshots with btrbk";

    onCalendar = lib.mkOption {
      type = lib.types.str;
      default = "*-*-* 00,12:00:00";
      description = "Systemd calendar expression controlling snapshot frequency";
    };

    snapshotPreserveMin = lib.mkOption {
      type = lib.types.str;
      default = "24h";
      description = "Period during which every snapshot is retained";
    };

    snapshotPreserve = lib.mkOption {
      type = lib.types.str;
      default = "14d";
      description = "Daily snapshot retention";
    };

    sourceVolume = lib.mkOption {
      type = lib.types.str;
      default = "/btr_pool";
      description = "Mounted Btrfs top-level volume containing the source subvolume";
    };

    sourceSubvolume = lib.mkOption {
      type = lib.types.str;
      default = "@persistent";
      description = "Btrfs subvolume to snapshot, relative to sourceVolume";
    };

    snapshotDirectory = lib.mkOption {
      type = lib.types.str;
      default = "/snapshots";
      description = "Mounted Btrfs subvolume in which snapshots are created";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = builtins.hasAttr cfg.sourceVolume config.fileSystems;
        message = "services'.btrbk.sourceVolume must be a configured filesystem mount";
      }
      {
        assertion = builtins.hasAttr cfg.snapshotDirectory config.fileSystems;
        message = "services'.btrbk.snapshotDirectory must be a configured filesystem mount";
      }
    ];

    services.btrbk = {
      # Snapshot creation is fast, but pruning should remain unobtrusive on a
      # laptop when it catches up after being powered off.
      niceness = 15;
      ioSchedulingClass = "idle";

      instances.persistent = {
        inherit (cfg) onCalendar;

        settings = {
          timestamp_format = "long-iso";
          snapshot_preserve_min = cfg.snapshotPreserveMin;
          snapshot_preserve = cfg.snapshotPreserve;

          volume.${cfg.sourceVolume} = {
            snapshot_dir = cfg.snapshotDirectory;
            subvolume.${cfg.sourceSubvolume}.snapshot_create = "always";
          };
        };
      };
    };

    systemd.services.btrbk-persistent.unitConfig.RequiresMountsFor = [
      cfg.sourceVolume
      cfg.snapshotDirectory
    ];
  };
}
