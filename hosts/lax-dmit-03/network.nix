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
    };
  };

  # DNS
  services.resolved.enable = false;

  environment.etc."resolv.conf".text = ''
    nameserver 1.1.1.1
    nameserver 2606:4700:4700::1111
    options edns0 trust-ad
  '';
}
