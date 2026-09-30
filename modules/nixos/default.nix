{ ... }:
{
  imports = [
    ../common/nix.nix
    ./desktop
    ./development
    ./hardware
    ./security
    ./services
    ./system
    ./user
  ];
}
