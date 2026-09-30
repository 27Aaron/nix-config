{
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  enable = osConfig.desktop'.fcitx5.enable;
in
{
  i18n.inputMethod = lib.mkIf enable {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-gtk
        (fcitx5-rime.override {
          rimeDataPkgs = [ rime-ice ];
        })
        (qt6Packages.fcitx5-configtool.override { kcmSupport = false; })
      ];
    };
  };

  xdg.dataFile."fcitx5/rime/default.custom.yaml" = lib.mkIf enable {
    text = ''
      patch:
        __include: rime_ice_suggestion:/
        schema_list:
          - schema: rime_ice
    '';
  };
}
