{
  config,
  lib,
  ...
}:
let
  cfg = config.desktop'.cursors;
in
{
  options.desktop'.cursors = {
    enable = lib.mkEnableOption "Bibata cursor theme";
  };

  config = lib.mkIf cfg.enable {
    # Cursor theme links managed by home.pointerCursor under ~/.icons.
    preservation'.user.directories = [ ".icons" ];
  };
}
