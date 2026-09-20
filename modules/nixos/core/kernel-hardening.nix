{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.core'.kernel-hardening;
in
{
  options.core'.kernel-hardening = {
    enable = lib.mkEnableOption ''
      kernel module blocking mitigating the Dirty Frag LPE (esp4, esp6,
      rxrpc). Harmless unless IPsec ESP or AF_RXRPC is actually used.
    '';
  };

  config = lib.mkIf cfg.enable {
    # `install ... false` rejects every load request, including explicit
    # `modprobe` calls, which subsumes a blacklist (auto-loading only).
    boot.extraModprobeConfig = ''
      install esp4 ${pkgs.coreutils}/bin/false
      install esp6 ${pkgs.coreutils}/bin/false
      install rxrpc ${pkgs.coreutils}/bin/false
    '';
  };
}
