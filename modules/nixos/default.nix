{ ... }:
{
  imports = [
    ../common/nix.nix
    ./hardware
    ./services
    ./system
  ];
}
