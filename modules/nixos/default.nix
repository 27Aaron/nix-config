{ ... }:
{
  imports = [
    ../common/nix.nix
    ./disko.nix
    ./persistence.nix
    ./services
  ];
}
