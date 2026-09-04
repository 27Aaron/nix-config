{
  lib,
  config,
  ...
}: let
  cfg = config.services'.avahi;
in {
  options.services'.avahi = {
    enable = lib.mkEnableOption ''
      Avahi mDNS/Zeroconf: resolve and publish .local hostnames on the LAN
      (e.g. ssh <hostname>.local), and discover network printers for CUPS.
    '';
  };

  config = lib.mkIf cfg.enable {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;

      # Advertise this machine itself on the LAN, so peers can discover it
      # and reach it at <hostname>.local without knowing its IP.
      publish = {
        enable = true;
        domain = true;
        userServices = true;
      };
    };
  };
}
