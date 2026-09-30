{ ... }:
{
  imports = [
    ../common/nix.nix
    ./hardware
    ./security
    ./services
    ./system
  ];
}
