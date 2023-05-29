{
  imports = [
    ./network.nix
    ./hardware.nix
  ];

  # LAX CloudCone 4C-4G-80G

  # Infrastructure
  security'.firewall.enable = true;
  services'.openssh.enable = true;
  services'.vnstat.enable = true;

  # Application stack
  services'.snell-server.enable = true;
}
