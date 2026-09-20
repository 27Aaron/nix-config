{
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot = {
    # Classic interface naming: the NIC shows up as eth0 instead of a
    # predictable name like ens18. audit=0 turns off the kernel audit
    # subsystem, whose event log is noise on a home router VM.
    kernelParams = [
      "audit=0"
      "net.ifnames=0"
    ];
  };

  hardware'.systemd-boot.enable = true;
  # The VM was installed with a 256M ESP; keep fewer generations so it does
  # not fill up with LTO kernels (~50M per generation).
  boot.loader.systemd-boot.configurationLimit = 4;

  # Guest storage and virtio modules come from the qemu-guest profile above
  # and hardware'.qemu; the NixOS initrd defaults cover SATA/USB/SCSI, so
  # this host keeps no hand-written module list.
  hardware'.qemu.enable = true;

  # Keep the balloon driver disabled: the host reclaiming memory from this
  # VM would starve the router.
  hardware'.disable-balloon.enable = true;

  # PVE uses the guest agent for clean shutdown and IP reporting.
  services.qemuGuest.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Matches the layout in docs/example/btrfs-subvolumes.nix.
  hardware' = {
    disko = {
      enable = true;
      device = "/dev/sda";
      tmpfsSize = "512M";
    };
    persistence.enable = true;
  };
}
