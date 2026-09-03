{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.desktop'.fcitx5;
in {
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
          (qt6Packages.fcitx5-configtool.override {kcmSupport = false;})
        ];
      };
    };

    # Keep the input method group declarative. Fcitx5 rewrites this file when
    # input methods are changed at runtime, so force the desired profile back
    # during every Home Manager activation.
    hm'.xdg.configFile."fcitx5/profile" = {
      source = ./fcitx5/profile;
      force = true;
    };

    preservation'.user.directories = [
      # Fcitx5
      ".config/fcitx5"
      ".local/share/fcitx5"
    ];
  };
}
