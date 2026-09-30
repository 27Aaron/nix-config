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
    preservation'.user.directories = [
      ".config/mozilla"
      ".mozilla"
    ];
  };
}
