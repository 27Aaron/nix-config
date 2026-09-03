{
  lib,
  config,
  ...
}: let
  cfg = config.services'.tang;
in {
  options.services'.tang = {
    enable = lib.mkEnableOption "Tang key derivation service";

    port = lib.mkOption {
      type = lib.types.port;
      default = 7654;
      description = "TCP port on which Tang listens";
    };

    ipAddressAllow = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["0.0.0.0/0"];
      description = ''
        Source addresses (IPs or CIDR prefixes) allowed to reach Tang,
        applied by upstream as a systemd socket whitelist.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.tang = {
      enable = true;
      listenStream = [(toString cfg.port)];
      ipAddressAllow = cfg.ipAddressAllow;
    };

    networking.firewall.allowedTCPPorts = [cfg.port];
  };
}
