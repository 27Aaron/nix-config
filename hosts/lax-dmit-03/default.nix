{
  imports = [
    ./network.nix
    ./hardware.nix
  ];

  # LAX DMIT Echo 1C-1G-20G

  # Infrastructure
  services'.vnstat.enable = true;
  services'.openssh.enable = true;
  security'.firewall.enable = true;

  # Application stack
  services'.sing-box.enable = true;
  services'.snell-server.enable = true;
}
