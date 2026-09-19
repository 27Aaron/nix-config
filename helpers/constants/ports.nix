# Service port registry. Modules and hosts reference these constants
# instead of bare numbers, so a port lives in exactly one place.
{ lib, ... }:
rec {
  port = {
    initrdSsh = 22; # SSH inside initrd, used for remote LUKS unlock.
    openssh = 233; # OpenSSH daemon.
    postgresql = 5432; # PostgreSQL.
    tang = 7654; # Tang key derivation service.
  };

  # String form for config templates and string interpolation, since Nix
  # refuses to coerce an integer inside a string.
  portStr = lib.mapAttrsRecursive (_: builtins.toString) port;
}
