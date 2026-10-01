{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.desktop'.fcitx5;
in
{
  options.desktop'.fcitx5 = {
    enable = lib.mkEnableOption "Fcitx5 input method";
  };

  config = lib.mkIf cfg.enable {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        waylandFrontend = true;
        addons = with pkgs; [
          fcitx5-gtk
          fcitx5-rime
        ];
      };
    };
  };
}
