{ config, lib, ... }:
let
  cfg = config.services'.btrbk;
in
{
  options.services'.btrbk = {
    enable = lib.mkEnableOption "local Btrfs snapshots with btrbk";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = builtins.hasAttr "/btr_pool" config.fileSystems;
        message = "services'.btrbk requires a /btr_pool filesystem mount";
      }
      {
        assertion = builtins.hasAttr "/snapshots" config.fileSystems;
        message = "services'.btrbk requires a /snapshots filesystem mount";
      }
    ];

    services.btrbk = {
      niceness = 15;
      ioSchedulingClass = "idle";
      instances.persistent = {
        onCalendar = "*-*-* 00,12:00:00";
        settings = {
          timestamp_format = "long-iso";
          snapshot_preserve_min = "24h";
          snapshot_preserve = "14d";
          volume."/btr_pool" = {
            snapshot_dir = "/snapshots";
            subvolume."@persistent".snapshot_create = "always";
          };
        };
      };
    };

    systemd.services.btrbk-persistent.unitConfig.RequiresMountsFor = [
      "/btr_pool"
      "/snapshots"
    ];

    preservation'.os.directories = lib.mkIf config.hardware'.persistence.enable [
      {
        directory = "/var/lib/btrbk";
        user = "btrbk";
        group = "btrbk";
        mode = "0750";
      }
    ];
  };
}
