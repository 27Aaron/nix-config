{
  imports = [
    ./hardware.nix
  ];

  networking.networkmanager.enable = true;

  security'.firewall.enable = true;

  services' = {
    openssh.enable = true;
    vnstat.enable = true;
  };
}
