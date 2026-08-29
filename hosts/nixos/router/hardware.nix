{
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot = {
    initrd.availableKernelModules = ["uhci_hcd" "ehci_pci" "ahci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod"];
    initrd.kernelModules = [];
    # The system runs as a PVE guest and does not host KVM guests itself.
    kernelModules = [];
    extraModulePackages = [];

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  # PVE uses the guest agent for clean shutdown and IP reporting.
  services.qemuGuest.enable = true;

  # Headless VM: systemd-networkd instead of NetworkManager.
  networking = {
    useNetworkd = true;
    useDHCP = false;
  };

  systemd.network.networks."10-ether" = {
    matchConfig.Type = "ether";
    networkConfig.DHCP = "yes";
  };

  services.resolved.enable = true;

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
