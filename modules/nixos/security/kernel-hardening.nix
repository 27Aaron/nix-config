{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.security'.kernel-hardening;
in {
  options.security'.kernel-hardening = {
    enable = lib.mkEnableOption ''
      kernel module blacklist mitigating the Dirty Frag LPE (esp4, esp6,
      rxrpc). Harmless unless IPsec ESP or AF_RXRPC is actually used.
    '';
  };

  config = lib.mkIf cfg.enable {
    boot.blacklistedKernelModules = ["esp4" "esp6" "rxrpc"];

    boot.extraModprobeConfig = ''
      install esp4 ${pkgs.coreutils}/bin/false
      install esp6 ${pkgs.coreutils}/bin/false
      install rxrpc ${pkgs.coreutils}/bin/false
    '';
  };
}
