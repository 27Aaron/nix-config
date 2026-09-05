{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.desktop'.fcitx5;
  wanxiangModel = pkgs.fetchurl {
    url = "https://github.com/amzxyz/RIME-LMDG/releases/download/LTS/wanxiang-lts-zh-hans.gram";
    # Upstream replaces this asset in place; verify its contents on updates.
    hash = "sha256-ZU1/H+Sxvz1CX4wKRKxhQj3tWMeEJntN8DJWAw1yIz8=";
  };
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
          (fcitx5-rime.override {
            rimeDataPkgs = [rime-wanxiang];
          })
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

    hm'.xdg.dataFile = {
      "fcitx5/rime/default.custom.yaml".text = ''
        patch:
          __include: wanxiang_suggested_default:/
          schema_list:
            - schema: wanxiang
      '';
      "fcitx5/rime/wanxiang-lts-zh-hans.gram".source = wanxiangModel;
    };

    preservation'.user.directories = [
      # Fcitx5
      ".config/fcitx5"
      ".local/share/fcitx5"
    ];
  };
}
