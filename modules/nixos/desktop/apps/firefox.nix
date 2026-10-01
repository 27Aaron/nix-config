{
  config,
  lib,
  ...
}:
let
  cfg = config.desktop'.apps.firefox;
in
{
  options.desktop'.apps.firefox = {
    enable = lib.mkEnableOption "Firefox";
  };

  config = lib.mkIf cfg.enable {
    hm'.programs.firefox.enable = true;
    preservation'.user.directories = lib.mkIf (config.hardware'.persistence.enable) [
      ".config/mozilla"
      ".mozilla"
    ];
  };
}
