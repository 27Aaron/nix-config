{
  systemd.network.enable = true;
  services.resolved.enable = false;
  networking.useDHCP = false;
  networking.useNetworkd = true;
  networking.resolvconf.enable = false;

  environment.etc."resolv.conf" = {
    text = ''
      nameserver 1.1.1.1
      nameserver 2606:4700:4700::1111
      options edns0 trust-ad
    '';
  };

  systemd.network.networks."10-eth0" = {
    DHCP = "yes";
    matchConfig.Name = "eth0";
  };
}
