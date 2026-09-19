#####################################################
#
# Router - A NixOS VM running on Proxmox
#   (4 vCPU, 1 GB RAM, 32 GB disk)
#
#####################################################
{ lib, ... }:
{
  imports = [
    ./hardware.nix
    ./network.nix
  ];

  # Avoid concurrent local builds exhausting the VM's 1 GB memory limit.
  nix.settings.max-jobs = 1;

  # Replace the default journald bounds entirely; the 1 GB VM should not
  # keep the 256M in-RAM journal.
  services.journald.settings.Journal = lib.mkForce {
    SystemMaxUse = "128M";
  };

  services' = {
    openssh.enable = true;
    openssh.port = 233;
    vnstat.enable = true;
    zram.enable = true;
  };

  security'.firewall.enable = true;
  security'.kernel-hardening.enable = true;

  system.stateVersion = "26.05";
}
