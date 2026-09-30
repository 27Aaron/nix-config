{
  config,
  lib,
  ...
}:
let
  cfg = config.desktop'.fcitx5;
in
{
  options.desktop'.fcitx5 = {
    enable = lib.mkEnableOption "Fcitx5 state persistence";
  };

  config = lib.mkIf cfg.enable {
    preservation'.user.directories = [
      ".config/fcitx5"
      ".local/share/fcitx5"
    ];
  };
}
