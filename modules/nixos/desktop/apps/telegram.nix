{
  config,
  lib,
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
    preservation'.user.directories = [
      # Telegram Desktop session data and settings, including tdata.
      ".local/share/TelegramDesktop"
    ];
  };
}
