{...}: {
  imports = [
    ./hardware.nix
  ];

  services' = {
    networkmanager.enable = true;
    openssh.enable = true;
    vnstat.enable = true;
    zram.enable = true;
  };

  security'.firewall.enable = true;
}
