{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.desktop'.apps.telegram;
in
{
  options.desktop'.apps.telegram = {
    enable = lib.mkEnableOption "Telegram Desktop";
  };

  config = lib.mkIf cfg.enable {
    hm'.home.packages = [ pkgs.telegram-desktop ];

    preservation'.user.directories = lib.mkIf config.hardware'.persistence.enable [
      ".local/share/TelegramDesktop"
    ];
  };
}
