{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.core'.kernel-hardening;
in
{
  options.core'.kernel-hardening = {
    enable = lib.mkEnableOption ''
      kernel module blocking for the esp4, esp6, and rxrpc modules
    '';
  };

  config = lib.mkIf cfg.enable {
    boot.extraModprobeConfig = ''
      install esp4 ${pkgs.coreutils}/bin/false
      install esp6 ${pkgs.coreutils}/bin/false
      install rxrpc ${pkgs.coreutils}/bin/false
    '';
  };
}
