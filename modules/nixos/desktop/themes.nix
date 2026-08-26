{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.desktop'.themes;
in {
  options.desktop'.themes = {
    enable = lib.mkEnableOption "GTK and icon themes";
  };

  config = lib.mkIf cfg.enable {
    hm'.home.packages = with pkgs; [
      gtk3
      gtk4
    ];

    hm'.gtk = {
      enable = true;

      theme = {
        package = pkgs.adw-gtk3;
        name = "adw-gtk3-dark";
      };

      iconTheme = {
        package = pkgs.papirus-icon-theme;
        name = "Papirus-Dark";
      };

      font = {
        package = pkgs.cantarell-fonts;
        name = "Cantarell Regular";
        size = 12;
      };
    };

    hm'.dconf.settings."org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
}
