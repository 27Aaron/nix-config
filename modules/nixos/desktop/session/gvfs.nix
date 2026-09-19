{
  config,
  lib,
  ...
}:
let
  cfg = config.services'.gvfs;
in
{
  options.services'.gvfs = {
    enable = lib.mkEnableOption "GVfs userspace virtual filesystem";
  };

  config = {
    services.gvfs.enable = lib.mkIf cfg.enable true;

    # Upstream consumers may enable this service on their own, so persistence
    # follows the final service state, whoever turned it on.
    preservation'.user.directories = lib.optionals config.services.gvfs.enable [
      # File manager metadata: trash, network locations and MTP
      {
        directory = ".local/share/gvfs-metadata";
        mode = "0700";
      }
    ];
  };
}
