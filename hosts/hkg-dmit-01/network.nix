{inputs, ...}: let
  secrets = import "${inputs.my-secrets}/hosts/hkg-dmit-01/network.nix";
in {
  # Networking
  networking = {
    useDHCP = false;
    useNetworkd = true;
    resolvconf.enable = false;
  };

  systemd.network = {
    enable = true;
    networks."10-eth0" = {
      matchConfig.Name = "eth0";
      inherit (secrets) address;
      networkConfig = {
        IPv6AcceptRA = false;
        LinkLocalAddressing = "ipv6";
      };
      routes = secrets.routes;
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
