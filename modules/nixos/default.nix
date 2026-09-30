{ ... }:
{
  imports = [
    ../common/nix.nix
    ./desktop
    ./hardware
    ./security
    ./services
    ./system
  ];
}
