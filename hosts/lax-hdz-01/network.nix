{pkgs, ...}: {
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

  systemd.services.fix-ipv6-privacy = {
    description = "Force disable IPv6 Privacy Extensions after network is up";
    after = [
      "network-online.target"
      "systemd-networkd.service"
    ];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.bash}/bin/bash -c 'sleep 2; ${pkgs.procps}/bin/sysctl -w net.ipv6.conf.all.use_tempaddr=0 net.ipv6.conf.default.use_tempaddr=0 net.ipv6.conf.eth0.use_tempaddr=0'";
    };
  };
}
