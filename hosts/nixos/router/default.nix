{...}: {
  imports = [
    ./hardware.nix
  ];

  services' = {
    btrfs-scrub.enable = true;
    openssh.enable = true;
    vnstat.enable = true;
    zram.enable = true;
  };

  security'.firewall.enable = true;

  system.stateVersion = "26.11";
}
