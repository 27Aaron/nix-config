{
  imports = [
    ./network.nix
    ./hardware.nix
  ];

  # LAX HostDZire 4C-6G-100G

  # Infrastructure
  security'.firewall.enable = true;
  services'.openssh.enable = true;
  services'.vnstat.enable = true;

  # Application stack
  services'.snell-server.enable = true;
}
