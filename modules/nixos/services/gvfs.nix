{ config, lib, ... }:
let
  cfg = config.services'.gvfs;
in
{
  options.services'.gvfs = {
    enable = lib.mkEnableOption "GVfs userspace virtual filesystem";
  };

  config = {
    services.gvfs.enable = lib.mkIf cfg.enable true;

    preservation'.user.directories = lib.mkIf (cfg.enable && config.hardware'.persistence.enable) [
      {
        directory = ".local/share/gvfs-metadata";
        mode = "0700";
      }
    ];
  };
}
