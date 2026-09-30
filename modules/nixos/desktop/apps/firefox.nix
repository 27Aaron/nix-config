{
  config,
  lib,
  pkgs,
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
    environment.systemPackages = [ pkgs.firefox ];

    preservation'.user.directories = [
      ".config/mozilla"
      ".mozilla"
    ];
  };
}
