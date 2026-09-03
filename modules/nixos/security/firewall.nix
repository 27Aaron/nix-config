{
  config,
  lib,
  ...
}: let
  cfg = config.security'.firewall;
in {
  options.security'.firewall = {
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

    preservation'.os.directories = ["/var/lib/nftables"];
  };
}
