# NixOS system modules shared by every host.
{ ... }:
{
  imports = [
    ./disko.nix
    ./persistence.nix
  ];
}
