# Shared helper library for modules and hosts. Extend here as more
# constants or functions are added under helpers/.
{ lib }:
let
  ports = import ./constants/ports.nix { inherit lib; };
in
{
  inherit (ports) port portStr;
}
