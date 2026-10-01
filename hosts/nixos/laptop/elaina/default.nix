{
  system = "x86_64-linux";

  modules = [
    ../../../../profiles/nixos/default.nix
    ./configuration.nix
  ];
}
