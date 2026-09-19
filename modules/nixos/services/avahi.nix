{
  lib,
  config,
  helpers,
  ...
}:
let
  cfg = config.services'.avahi;
in
{
  options.services'.avahi = {
    enable = lib.mkEnableOption ''
      Avahi mDNS/Zeroconf: resolve and publish .local hostnames on the LAN
      (e.g. ssh <hostname>.local), and discover network printers for CUPS.
    '';
  };

  config = lib.mkIf cfg.enable {
    # The daemon listens on UDP 5353 by protocol and has no port option;
    # assert the registry entry matches instead of letting it drift.
    assertions = [
      {
        assertion = helpers.port.avahi == 5353;
        message = "helpers.port.avahi must stay 5353: mDNS is fixed at UDP 5353 and avahi cannot be rebound";
      }
    ];

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
