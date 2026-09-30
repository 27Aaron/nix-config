{
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  enable = osConfig.desktop'.apps.telegram.enable;
in
{
  home.packages = lib.mkIf enable [ pkgs.telegram-desktop ];
}
