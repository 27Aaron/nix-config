# Shared helper library for modules and hosts.
let
  nix = import ./constants/nix.nix;
  ports = import ./constants/ports.nix;
  user = import ./constants/user.nix;
  path = import ./constants/path.nix { inherit user; };
in
{
  inherit
    nix
    path
    user
    ;
  inherit (ports) port;
}
