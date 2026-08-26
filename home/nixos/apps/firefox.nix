{
  config,
  lib,
  ...
}: let
  cfg = config.home'.apps.firefox;
in {
  options.home'.apps.firefox.enable = lib.mkEnableOption "Firefox";

  config = lib.mkIf cfg.enable {
    programs.firefox.enable = true;
  };
}
