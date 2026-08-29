{...}: {
  # Headless VM: systemd-networkd instead of NetworkManager.
  networking = {
    useNetworkd = true;
    useDHCP = false;
  };

  services.resolved.enable = true;

  systemd.network.networks."10-eth0" = {
    matchConfig.Name = "eth0";
    networkConfig = {
      # IPv4 comes from the static address; IPv6 addresses and routes are
      # obtained through DHCPv6 and router advertisements.
      Address = "10.77.77.66/24";
      Gateway = "10.77.77.1";
      DNS = ["10.77.77.1"];
      DHCP = "ipv6";
    };
  };
}
