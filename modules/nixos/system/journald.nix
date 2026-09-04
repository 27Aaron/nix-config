{lib, ...}: {
  # Keep the persisted /var/log journal bounded instead of growing with the
  # disk, bound the in-RAM early-boot journal as well; hosts with tighter
  # constraints override this (e.g. router: 128M).
  services.journald.extraConfig = lib.mkDefault ''
    SystemMaxUse=2G
    RuntimeMaxUse=256M
  '';
}
