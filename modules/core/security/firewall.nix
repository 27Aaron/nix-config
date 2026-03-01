{
  lib,
  config,
  ...
}:
let
  cfg = config.security'.firewall;
in
{
  options.security'.firewall = {
    enable = lib.mkEnableOption "Firewall with nftables";
  };

  config = lib.mkIf cfg.enable {
    networking = {
      firewall = {
        enable = lib.mkDefault true;
        allowPing = lib.mkDefault true;
      };
      nftables.enable = lib.mkDefault true;
    };
  };
}
