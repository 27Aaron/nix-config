{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  enable = osConfig.desktop'.cursors.enable;
in
{
  config = lib.mkIf enable {
    assertions = [
      {
        assertion = config.gtk.enable;
        message = "desktop'.cursors requires the GTK module (desktop'.themes) to apply the cursor theme to GTK applications";
      }
    ];

    home.pointerCursor = {
      enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 32;
      gtk.enable = true;
    };
  };
}
