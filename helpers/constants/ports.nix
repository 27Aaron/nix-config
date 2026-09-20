# Service port registry. Modules and hosts reference these constants
# instead of bare numbers, so a port lives in exactly one place.
#
# Ports fixed by protocol or upstream (resolved, avahi) have no port
# option to rebind; their modules assert the registered value stays in
# sync.
{
  port = {
    initrdSsh = 22; # SSH inside initrd, used for remote LUKS unlock.
    resolved = 53; # systemd-resolved stub listener (loopback, router).
    openssh = 233; # OpenSSH daemon.
    avahi = 5353; # Avahi mDNS: LAN hostname discovery.
  };
}
