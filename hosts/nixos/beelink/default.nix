#####################################################
#
# Beelink SER6 Pro VEST - homelab server
#   (Ryzen 7 7735HS, 64 GB DDR5, 4 TB NVMe SSD)
#
#####################################################
{...}: {
  imports = [
    ./hardware.nix
  ];

  services' = {
    btrbk.enable = true;
    btrfs-scrub.enable = true;
    coder = {
      enable = true;
      listenAddress = "0.0.0.0:34567";
      accessUrl = "https://coder.in.ou.al";
      wildcardAccessUrl = "*.coder.in.ou.al";
      openFirewall = true;
    };
    networkmanager.enable = true;
    openssh.enable = true;
    postgresql.enable = true;
    smartd.enable = true;
    vnstat.enable = true;
    zram.enable = true;
  };

  security'.firewall.enable = true;

  tools'.dev.enable = true;

  system.stateVersion = "26.05";
}
