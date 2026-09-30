{
  config,
  lib,
  ...
}:
let
  cfg = config.desktop'.themes;
in
{
  options.desktop'.themes = {
    enable = lib.mkEnableOption "GTK, Qt and icon themes";
  };

  config = lib.mkIf cfg.enable {
    # State read and written through the managed GTK setup.
    preservation'.user.directories = [
      {
        directory = ".config/gtk-3.0";
        mode = "0700";
      }
      {
        directory = ".config/dconf";
        mode = "0700";
      }
    ];
  };
}
