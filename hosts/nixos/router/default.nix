# Router - NixOS VM on Proxmox (4 vCPU, 1 GB RAM, 32 GB disk)
{
  system = "x86_64-linux";
  stateVersion = "26.05";

  modules = [
    ./hardware.nix
    ./storage.nix
    ./network.nix
    ./system.nix
  ];
}
