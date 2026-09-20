# Service port registry: modules and hosts reference these constants instead of
# bare numbers. Ports fixed by protocol or upstream (resolved, avahi) have no
# port option to rebind, so their modules assert the registered value stays in sync.
{
  port = {
    initrdSsh = 22; # SSH inside initrd, used for remote LUKS unlock.
    resolved = 53; # systemd-resolved stub listener (loopback, router).
    openssh = 233; # OpenSSH daemon.
    avahi = 5353; # Avahi mDNS: LAN hostname discovery.
  };
}
