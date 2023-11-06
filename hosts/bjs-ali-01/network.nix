{lib, ...}: {
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
    };
  };

  # DNS
  services.resolved.settings.Resolve = {
    Cache = "no-negative";
    LLMNR = false;
    MulticastDNS = false;
  };

  environment.etc."resolv.conf".text = lib.mkForce ''
    nameserver 223.5.5.5
    nameserver 223.6.6.6
    options edns0 trust-ad
  '';
}
