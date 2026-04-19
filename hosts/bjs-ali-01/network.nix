{
  # Networking
  networking = {
    useDHCP = false;
    useNetworkd = true;
    resolvconf.enable = false;
  };

  systemd.network = {
    enable = true;
    networks."10-eth0" = {
      DHCP = "yes";
      matchConfig.Name = "eth0";
      dns = [ "223.5.5.5" "223.6.6.6" ];
    };
  };

  # DNS
  services.resolved.settings.Resolve = {
    Cache = "no-negative";
    LLMNR = false;
    MulticastDNS = false;
  };
}
