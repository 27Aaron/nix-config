{
  config,
  inputs,
  lib,
  modulesPath,
  pkgs,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  nixpkgs = {
    hostPlatform = lib.mkDefault "x86_64-linux";
    overlays = [inputs.nix-cachyos-kernel.overlays.pinned];
  };

  boot = {
    initrd = {
      availableKernelModules = ["nvme" "xhci_pci" "thunderbolt" "usbhid" "usb_storage" "sd_mod"];
    };

    kernelModules = ["kvm-amd"];
    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3;

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  storage' = {
    disko = {
      enable = true;
      device = "/dev/nvme0n1";
      espSize = "1G";
      luks.enable = true;
    };
    persistence.enable = true;
  };

  hardware'.amdgpu.enable = true;

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
