# NixOS system modules shared by every host.
{ ... }:
{
  imports = [
    ../common/nix.nix
    ./disko.nix
    ./persistence.nix
  ];
}
