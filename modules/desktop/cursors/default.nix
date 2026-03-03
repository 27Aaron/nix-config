{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.desktop'.cursors;
in {
  options.desktop'.cursors = {
    enable = lib.mkEnableOption "Bibata cursor theme";
  };

  config = lib.mkIf cfg.enable {
    hm'.home.pointerCursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 32;
      gtk.enable = true;
    };
  };
}
