{ lib, ... }:
{
  # Bound the persisted /var/log journal and the in-RAM early-boot journal;
  # hosts with tighter constraints override this (e.g. router: 128M).
  services.journald.settings.Journal = lib.mkDefault {
    SystemMaxUse = "2G";
    RuntimeMaxUse = "256M";
  };
}
