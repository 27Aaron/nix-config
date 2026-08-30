{
  config,
  lib,
  ...
}: let
  cfg = config.security'.touch-id;
in {
  options.security'.touch-id = {
    enable = lib.mkEnableOption "Touch ID authentication for sudo";
  };

  config = lib.mkIf cfg.enable {
    security.pam.services.sudo_local.touchIdAuth = true;
  };
}
