{inputs, ...}: let
  secrets = import "${inputs.my-secrets}/network/lax-cc-02/network.nix";
in {
  systemd.network.enable = true;
  services.resolved.enable = false;
  networking.useDHCP = false;
  networking.useNetworkd = true;
  networking.resolvconf.enable = false;

  environment.etc."resolv.conf".text = ''
    nameserver 1.1.1.1
    nameserver 2606:4700:4700::1111
    options edns0 trust-ad
  '';

  systemd.network.networks."10-eth0" = {
    matchConfig.Name = "eth0";
    inherit (secrets) address;
    networkConfig = {
      IPv6AcceptRA = false;
      LinkLocalAddressing = "ipv6";
    };
    routes = secrets.routes;
  };
}
