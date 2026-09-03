{
  lib,
  config,
  ...
}: let
  cfg = config.security'.arp-filter;
in {
  options.security'.arp-filter = {
    enable = lib.mkEnableOption ''
      nftables ARP anti-spoofing: on the selected interfaces, ARP packets
      advertising a source address outside the allowed prefixes are dropped.
      Intended for hosts on shared L2 segments, such as cloud servers with
      public IPv4/IPv6.
    '';

    interfaces = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Interfaces on which ARP traffic is filtered";
    };

    allowedSubnets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = ''
        Source IP prefixes accepted in ARP on the protected interfaces,
        typically the host's own subnet. An empty list drops every ARP
        packet on those interfaces.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    networking.nftables.enable = lib.mkDefault true;

    networking.nftables.tables.arp-filter = {
      family = "arp";
      content = let
        # An empty set is invalid nft syntax, so a dummy prefix matching no
        # real traffic stands in for "block everything".
        subnets =
          if cfg.allowedSubnets == []
          then ["0.0.0.0/32"]
          else cfg.allowedSubnets;
      in ''
        chain input {
          type filter hook input priority 0; policy accept;
          ${lib.concatMapStringsSep "\n" (iface: ''
            iifname "${iface}" arp saddr ip != { ${lib.concatStringsSep ", " subnets} } drop
          '')
          cfg.interfaces}
        }

        chain output {
          type filter hook output priority 0; policy accept;
          ${lib.concatMapStringsSep "\n" (iface: ''
            oifname "${iface}" arp daddr ip != { ${lib.concatStringsSep ", " subnets} } drop
          '')
          cfg.interfaces}
        }
      '';
    };
  };
}
