{
  lib,
  pkgs,
  config,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  hardware'.disko-luks = {
    enable = true;
    swapSize = "32769M";
  };

  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];

  boot.initrd = {
    systemd.enable = true;
    availableKernelModules = [
      "nvme"
      "thunderbolt"
      "usbhid"
      "xhci_pci"
    ];
    kernelModules = [];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
