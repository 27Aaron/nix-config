{ helpers, ... }:
{
  # Headless VM: systemd-networkd instead of NetworkManager.
  networking = {
    useNetworkd = true;
    useDHCP = false;
  };

  services.resolved.enable = true;

  # The stub listener is fixed at port 53 (loopback only) and has no port
  # option; assert the registry entry matches instead of letting it drift.
  assertions = [
    {
      assertion = helpers.port.resolved == 53;
      message = "helpers.port.resolved must stay 53: systemd-resolved cannot rebind its stub listener";
    }
  ];

  systemd.network.networks."10-eth0" = {
    matchConfig.Name = "eth0";
    # IPv4 comes from the static address; IPv6 addresses and routes are
    # obtained through DHCPv6 and router advertisements.
    address = [ "10.77.77.66/24" ];
    gateway = [ "10.77.77.1" ];
    dns = [ "10.77.77.1" ];
    networkConfig.DHCP = "ipv6";
  };
}
