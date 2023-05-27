{
  imports = [
    ./network.nix
    ./hardware.nix
  ];

  # LAX CloudCone 1C-0.5G-40G
  services'.vnstat.enable = true;
  services'.openssh.enable = true;
  security'.firewall.enable = true;
}
