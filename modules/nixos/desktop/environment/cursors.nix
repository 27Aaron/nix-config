{
  config,
  lib,
  pkgs,
  username,
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
        message = "desktop'.cursors requires desktop'.themes";
      }
    ];

    hm'.home.pointerCursor = {
      enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 32;
      gtk.enable = true;
    };

    preservation.preserveAt."/persistent".users.${username}.directories =
      lib.mkIf (config.hardware'.persistence.enable)
        [ ".icons" ];
  };
}
