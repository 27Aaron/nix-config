{...}: {
  imports = [
    ./network.nix
    ./hardware.nix
  ];

  services' = {
    openssh.enable = true;
    vnstat.enable = true;
    zram.enable = true;
  };

  security'.firewall.enable = true;

  system.stateVersion = "26.11";
}
