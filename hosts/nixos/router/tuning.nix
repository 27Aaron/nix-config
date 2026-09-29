# Resource limits for a 1 GB VM.
{ lib, ... }:
{
  # Avoid concurrent local builds exhausting the VM's memory.
  nix.settings.max-jobs = 1;

  # Replace the default journald bounds entirely; the VM should not keep the
  # in-RAM journal that the defaults assume.
  services.journald.settings.Journal = lib.mkForce {
    SystemMaxUse = "128M";
  };
}
