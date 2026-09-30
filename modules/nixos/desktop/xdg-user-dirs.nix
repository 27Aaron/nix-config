{
  config,
  lib,
  ...
}:
let
  cfg = config.desktop'.xdg-user-dirs;
in
{
  options.desktop'.xdg-user-dirs = {
    enable = lib.mkEnableOption "XDG user directories";
  };

  config = lib.mkIf cfg.enable {
    preservation'.user.directories = [
      {
        directory = "Desktop";
        mountOptions = [ "x-gvfs-trash" ];
      }
      {
        directory = "Documents";
        mountOptions = [ "x-gvfs-trash" ];
      }
      {
        directory = "Downloads";
        mountOptions = [ "x-gvfs-trash" ];
      }
      {
        directory = "Music";
        mountOptions = [ "x-gvfs-trash" ];
      }
      {
        directory = "Pictures";
        mountOptions = [ "x-gvfs-trash" ];
      }
      {
        directory = "Videos";
        mountOptions = [ "x-gvfs-trash" ];
      }
    ];
  };
}
