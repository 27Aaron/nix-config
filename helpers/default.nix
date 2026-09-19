# Shared helper library for modules and hosts. Extend here as more
# constants or functions are added under helpers/.
{ lib }:
let
  nix = import ./constants/nix.nix;
  ports = import ./constants/ports.nix { inherit lib; };
in
{
  inherit nix;
  inherit (ports) port portStr;
}
