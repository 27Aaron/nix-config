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
  };

  config = lib.mkIf cfg.enable {
    services.tang = {
      enable = true;
      listenStream = [(toString cfg.port)];
      ipAddressAllow = ["0.0.0.0/0"];
    };

    networking.firewall.allowedTCPPorts = [cfg.port];
  };
}
