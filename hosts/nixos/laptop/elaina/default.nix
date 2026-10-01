{
  system = "x86_64-linux";

  modules = [
    ../../../../profiles/nixos/laptop.nix
    ./configuration.nix
    ./hardware.nix
  ];
}
