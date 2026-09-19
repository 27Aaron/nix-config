# Service port registry. Modules and hosts reference these constants
# instead of bare numbers, so a port lives in exactly one place.
#
# Ports fixed by protocol or upstream (resolved, avahi) have no port
# option to rebind; their modules assert the registered value stays in
# sync.
{ lib, ... }:
rec {
  port = {
    initrdSsh = 22; # SSH inside initrd, used for remote LUKS unlock.
    resolved = 53; # systemd-resolved stub listener (loopback, router).
    openssh = 233; # OpenSSH daemon.
    printing = 631; # CUPS IPP.
    avahi = 5353; # Avahi mDNS: LAN hostname and printer discovery.
    postgresql = 5432; # PostgreSQL.
    tang = 7654; # Tang key derivation service.
  };

  # String form for config templates and string interpolation, since Nix
  # refuses to coerce an integer inside a string.
  portStr = lib.mapAttrsRecursive (_: builtins.toString) port;
}
