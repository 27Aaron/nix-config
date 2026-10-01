{ config, lib, ... }:
let
  cfg = config.core'.firewall;
in
{
  options.core'.firewall = {
    enable = lib.mkEnableOption "firewall with nftables";
  };

  config = lib.mkIf cfg.enable {
    networking = {
      firewall.enable = true;
      nftables.enable = true;
    };
  };
}
