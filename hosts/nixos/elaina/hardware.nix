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
      availableKernelModules = ["nvme" "sd_mod" "thunderbolt" "usb_storage" "xhci_pci"];
      kernelModules = [];
    };

    kernelModules = ["kvm-amd"];
    extraModulePackages = [];
    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-zen4;

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  hardware' = {
    amdgpu.enable = true;
    bluetooth.enable = true;
  };

  storage' = {
    disko = {
      enable = true;
      device = "/dev/nvme0n1";
      espSize = "1G";
      swapSize = "32769M";
      luks.enable = true;
    };
    persistence.enable = true;
  };
}
