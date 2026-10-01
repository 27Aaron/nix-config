{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.desktop'.portal;
in
{
  options.desktop'.portal = {
    enable = lib.mkEnableOption "Wayland desktop portals";
  };

  config = lib.mkIf cfg.enable {
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    };
  };
}
