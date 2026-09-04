{
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot = {
    # Classic interface naming: the NIC shows up as eth0 instead of a
    # predictable name like ens18. audit=0 turns off the kernel audit
    # subsystem, whose event log is noise on a home router VM.
    kernelParams = ["audit=0" "net.ifnames=0"];

    initrd.availableKernelModules = ["uhci_hcd" "ehci_pci" "ahci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod"];
  };

  boot'.systemd-boot.enable = true;
  # The VM was installed with a 256M ESP; keep fewer generations so it does
  # not fill up with LTO kernels (~50M per generation).
  boot.loader.systemd-boot.configurationLimit = 4;

  # PVE uses the guest agent for clean shutdown and IP reporting.
  services.qemuGuest.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Matches the layout in docs/example/btrfs-subvolumes.nix.
  storage' = {
    disko = {
      enable = true;
      device = "/dev/sda";
      tmpfsSize = "512M";
    };
    persistence.enable = true;
  };
}
