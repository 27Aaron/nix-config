# Router - NixOS VM on Proxmox (4 vCPU, 1 GB RAM, 32 GB disk)
{ lib, ... }:
{
  modules = [
    ./hardware.nix
    ./network.nix

    {
      services'.fail2ban.enable = true;
      services'.openssh.enable = true;
      services'.vnstat.enable = true;
      services'.zram.enable = true;

      security'.firewall.enable = true;

      # Avoid concurrent local builds exhausting the VM's memory.
      nix.settings.max-jobs = 1;

      # Replace the default journald bounds entirely; the VM should not keep
      # the in-RAM journal that the defaults assume.
      services.journald.settings.Journal = lib.mkForce {
        SystemMaxUse = "128M";
      };
    }
  ];

  system = "x86_64-linux";
  stateVersion = "26.05";
}
