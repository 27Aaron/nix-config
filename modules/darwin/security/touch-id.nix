{
  config,
  lib,
  ...
}: {
  options.security'.touch-id = {
    enable = lib.mkEnableOption "Touch ID authentication for sudo";
  };

  config = lib.mkIf config.security'.touch-id.enable {
    security.pam.services.sudo_local.touchIdAuth = true;
  };
}
