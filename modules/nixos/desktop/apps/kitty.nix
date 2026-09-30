{ lib, ... }:
{
  options.desktop'.apps.kitty = {
    enable = lib.mkEnableOption "Kitty terminal emulator";
  };
}
