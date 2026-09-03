{
  lib,
  config,
  ...
}: let
  cfg = config.hardware'.qemu;
in {
  options.hardware'.qemu = {
    enable = lib.mkEnableOption "QEMU initrd configuration";
  };

  config = lib.mkIf cfg.enable {
    boot.initrd = {
      availableKernelModules = [
        "virtio_blk"
        "virtio_mmio"
        "virtio_net"
        "virtio_pci"
        "virtio_scsi"
      ];

      kernelModules = [
        "virtio_console"
        "virtio_rng"
      ];

      systemd.enable = true;
    };
  };
}
