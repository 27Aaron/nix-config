{
  config,
  lib,
  ...
}:
let
  cfg = config.core'.touch-id;
in
{
  options.core'.touch-id = {
    enable = lib.mkEnableOption "Touch ID authentication for sudo";
  };

  config = lib.mkIf cfg.enable {
    security.pam.services.sudo_local.touchIdAuth = true;
  };
}
