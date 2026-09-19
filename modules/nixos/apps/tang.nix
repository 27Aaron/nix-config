{
  config,
  helpers,
  lib,
  ...
}:
let
  cfg = config.services'.tang;
in
{
  options.services'.tang = {
    enable = lib.mkEnableOption "Tang key derivation service";

    port = lib.mkOption {
      type = lib.types.port;
      default = helpers.port.tang;
      description = "TCP port on which Tang listens";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open the Tang port in the firewall";
    };

    ipAddressAllow = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "192.168.1.0/24" ];
      description = ''
        Source addresses (IPs or CIDR prefixes) allowed to reach Tang,
        applied by upstream as a systemd socket whitelist. List every
        network whose clients unlock disks against this server; an empty
        list denies all clients.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.ipAddressAllow != [ ];
        message = "services'.tang.ipAddressAllow must list the client networks allowed to reach Tang";
      }
    ];

    services.tang = {
      enable = true;
      listenStream = [ (toString cfg.port) ];
      ipAddressAllow = cfg.ipAddressAllow;
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];
  };
}
