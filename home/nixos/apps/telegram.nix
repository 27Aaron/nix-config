{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.home'.apps.telegram;
in {
  options.home'.apps.telegram.enable = lib.mkEnableOption "AyuGram Desktop";

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.ayugram-desktop];
  };
}
