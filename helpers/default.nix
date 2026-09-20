# Shared helper library for modules and hosts. Extend here as more
# constants or functions are added under helpers/.
{ lib, platformName }:
let
  nix = import ./constants/nix.nix;
  ports = import ./constants/ports.nix { inherit lib; };
  user = import ./constants/user.nix;
  path = import ./constants/path.nix { inherit platformName user; };
in
{
  inherit
    nix
    path
    user
    ;
  inherit (ports) port portStr;
}
