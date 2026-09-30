# MECHREVO Wujie 14XA - Ryzen 7 8845HS laptop (32 GB RAM, 1 TB NVMe)
{ ... }:
{
  modules = [
    ./hardware.nix

    {
      services'.openssh.enable = true;
      services'.zram.enable = true;

      security'.firewall.enable = true;
    }
  ];

  system = "x86_64-linux";
  stateVersion = "26.05";
}
