{
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  enable = osConfig.desktop'.cursors.enable;
in
{
  home.pointerCursor = lib.mkIf enable {
    enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 32;
    gtk.enable = true;
  };
}
