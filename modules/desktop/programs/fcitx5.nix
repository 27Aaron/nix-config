{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.programs'.fcitx5;
in
{
  options.programs'.fcitx5 = {
    enable = lib.mkEnableOption "Fcitx5 input method";
  };

  config = lib.mkIf cfg.enable {
    i18n.inputMethod = {
      type = "fcitx5";
      enable = true;
      fcitx5 = {
        waylandFrontend = true;
        addons = with pkgs; [
          fcitx5-rime
          (qt6Packages.fcitx5-configtool.override { kcmSupport = false; })
        ];
      };
    };

    preservation'.user.directories = [
      ".config/fcitx5"
      ".local/share/fcitx5"
    ];
  };
}
