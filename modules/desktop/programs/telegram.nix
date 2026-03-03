{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.programs'.telegram;
in {
  options.programs'.telegram = {
    enable = lib.mkEnableOption "Telegram Desktop client (Ayugram)";
  };

  config = lib.mkIf cfg.enable {
    hm'.home.packages = with pkgs; [ayugram-desktop];

    preservation'.user.directories = [
      ".local/share/AyuGramDesktop"
    ];
  };
}
