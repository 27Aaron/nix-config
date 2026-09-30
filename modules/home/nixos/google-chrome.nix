{
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  enable = osConfig.desktop'.apps.google-chrome.enable;
in
{
  home.packages = lib.mkIf enable [ pkgs.google-chrome ];
}
