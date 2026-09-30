# Hardware profile for the Beelink SER6 Pro VEST (Ryzen 7 7735HS mini PC).
{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "thunderbolt"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];

    kernelModules = [ "kvm-amd" ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  hardware' = {
    amdgpu.enable = true;

    disko = {
      enable = true;
      device = "/dev/nvme0n1";
      espSize = "1G";
      luks.enable = true;
    };

    persistence.enable = true;
    systemd-boot.enable = true;
  };

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
