{
  lib,
  pkgs,
  ...
}:
let
  niriSession = lib.getExe' pkgs.niri "niri-session";
in
{
  programs.niri.enable = true;

  environment.systemPackages = [ pkgs.xwayland-satellite ];

  services.greetd = {
    enable = true;
    settings.default_session.command = "${lib.getExe pkgs.tuigreet} --time --cmd ${niriSession}";
  };
}
