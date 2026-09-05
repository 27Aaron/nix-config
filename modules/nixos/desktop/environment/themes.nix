{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.desktop'.themes;
  rosePineGtkSource = pkgs.fetchzip {
    url = "https://github.com/rose-pine/gtk/archive/3a11f84e11685aacaa749deea1e9f02872b99fdf.tar.gz";
    hash = "sha256-58HfkFvflQhiJzfHcJCihSE9YbxbD6Koe0/aT+PVv4w=";
  };
  rosePineMoonGtk = pkgs.runCommand "rose-pine-moon-gtk" {} ''
    theme="$out/share/themes/rose-pine-moon-gtk"
    mkdir -p "$theme/gtk-4.0"
    cp -rL ${rosePineGtkSource}/gtk3/rose-pine-moon-gtk/{gtk-3.0,gtk-3.20} "$theme/"
    chmod -R u+w "$theme"
    # Moon is already dark; upstream's alternate stylesheet inverts its colors.
    for version in gtk-3.0 gtk-3.20; do
      cp "$theme/$version/gtk.css" "$theme/$version/gtk-dark.css"
    done
    cp ${rosePineGtkSource}/gtk4/rose-pine-moon.css "$theme/gtk-4.0/gtk.css"
    cp "$theme/gtk-4.0/gtk.css" "$theme/gtk-4.0/gtk-dark.css"
  '';
in {
  options.desktop'.themes = {
    enable = lib.mkEnableOption "GTK, Qt and icon themes";
  };

  config = lib.mkIf cfg.enable {
    hm'.qt = {
      enable = true;
      platformTheme.name = "gtk3";
      style.name = "kvantum";
      kvantum = {
        enable = true;
        settings.General.theme = "rose-pine-moon-iris";
      };
    };

    hm'.xdg.configFile."Kvantum/rose-pine-moon-iris".source = "${pkgs.rose-pine-kvantum}/share/Kvantum/themes/rose-pine-moon-iris";

    hm'.gtk = {
      enable = true;

      theme = {
        package = rosePineMoonGtk;
        name = "rose-pine-moon-gtk";
      };

      gtk4.theme = {
        package = rosePineMoonGtk;
        name = "rose-pine-moon-gtk";
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

    # State read and written through the managed GTK setup above.
    preservation'.user.directories = [
      {
        directory = ".config/gtk-3.0";
        mode = "0700";
      }
      {
        directory = ".config/dconf";
        mode = "0700";
      }
    ];
  };
}
