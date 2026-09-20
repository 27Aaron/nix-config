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
    # net.ifnames=0 gives the NIC a classic eth0 name; audit=0 silences the
    # kernel audit log, which is pure noise on a home router VM.
    kernelParams = [
      "audit=0"
      "net.ifnames=0"
    ];
  };

  hardware'.systemd-boot.enable = true;
  # The VM was installed with a 256M ESP; keep fewer generations so it does
  # not fill up with LTO kernels (~50M per generation).
  boot.loader.systemd-boot.configurationLimit = 4;

  # No hand-written initrd module list: virtio comes from the qemu-guest
  # profile above, and the NixOS defaults cover SATA/USB/SCSI.

  # Keep the balloon driver disabled: the host reclaiming memory from
  # this VM would starve the router.
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
