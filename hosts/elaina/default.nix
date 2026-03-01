{
  imports = [
    ./hardware.nix
  ];

  security'.firewall.enable = true;

  services' = {
    networkmanager.enable = true;
    openssh.enable = true;
    vnstat.enable = true;
  };
}
