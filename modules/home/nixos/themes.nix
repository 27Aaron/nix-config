{
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  enable = osConfig.desktop'.themes.enable;

  rosePineGtkSource = pkgs.fetchzip {
    url = "https://github.com/rose-pine/gtk/archive/3a11f84e11685aacaa749deea1e9f02872b99fdf.tar.gz";
    hash = "sha256-58HfkFvflQhiJzfHcJCihSE9YbxbD6Koe0/aT+PVv4w=";
  };
  rosePineMoonGtk = pkgs.runCommand "rose-pine-moon-gtk" { } ''
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
in
{
  qt = lib.mkIf enable {
    enable = true;
    platformTheme.name = "gtk3";
    style.name = "kvantum";
    kvantum = {
      enable = true;
      settings.General.theme = "rose-pine-moon-iris";
    };
  };

  xdg.configFile."Kvantum/rose-pine-moon-iris" = lib.mkIf enable {
    source = "${pkgs.rose-pine-kvantum}/share/Kvantum/themes/rose-pine-moon-iris";
  };

  gtk = lib.mkIf enable {
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

  dconf = lib.mkIf enable {
    settings."org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
}
