{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.desktop'.cursors;
in
{
  options.desktop'.cursors = {
    enable = lib.mkEnableOption "Bibata cursor theme";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.hm'.gtk.enable;
        message = "desktop'.cursors requires the GTK module (desktop'.themes) to apply the cursor theme to GTK applications";
      }
    ];

    hm'.home.pointerCursor = {
      enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 32;
      gtk.enable = true;
    };

    # Cursor theme links managed by home.pointerCursor under ~/.icons.
    preservation'.user.directories = [
      ".icons"
    ];
  };
}
