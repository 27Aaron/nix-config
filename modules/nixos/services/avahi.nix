{ config, lib, ... }:
let
  cfg = config.services'.avahi;
in
{
  options.services'.avahi = {
    enable = lib.mkEnableOption ''
      Avahi mDNS/Zeroconf for resolving and publishing .local hostnames
    '';
  };

  config = lib.mkIf cfg.enable {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      publish = {
        enable = true;
        domain = true;
        userServices = true;
      };
    };
  };
}
