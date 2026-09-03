{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.desktop'.apps.telegram;
in {
  options.desktop'.apps.telegram = {
    enable = lib.mkEnableOption "AyuGram Desktop";
  };

  config = lib.mkIf cfg.enable {
    hm'.home.packages = [pkgs.ayugram-desktop];

    preservation'.user.directories = [
      # Telegram
      ".local/share/AyuGramDesktop"
    ];
  };
}
