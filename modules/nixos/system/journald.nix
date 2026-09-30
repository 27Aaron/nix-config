{ lib, ... }:
{
  # Bound the persisted /var/log journal and the in-RAM early-boot journal;
  # hosts with tighter constraints override this (e.g. router: 128M).
  #
  # `settings.Journal` is a submodule, so a whole-block `mkDefault` gets
  # shadowed by any plain definition; default the keys individually instead.
  services.journald.settings.Journal = {
    SystemMaxUse = lib.mkDefault "2G";
    RuntimeMaxUse = lib.mkDefault "256M";
  };
}
