{
  config,
  lib,
  ...
}:
let
  cfg = config.core'.firewall;
in
{
  options.core'.firewall = {
    enable = lib.mkEnableOption "Firewall with nftables";
  };

  config = lib.mkIf cfg.enable {
    networking = {
      firewall = {
        enable = true;
        allowPing = true;
      };
      nftables.enable = true;
    };

    # The nftables service owns /var/lib/nftables as a systemd StateDirectory
    # recreated on every boot, so it needs no persistence entry.
  };
}
