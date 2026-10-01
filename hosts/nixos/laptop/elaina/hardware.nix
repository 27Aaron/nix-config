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

  # Hardware profile for the MECHREVO WUJIE14XA laptop.
  boot = {
    initrd.availableKernelModules = [
      "nvme"
      "sd_mod"
      "thunderbolt"
      "usb_storage"
      "xhci_pci"
    ];
    kernelModules = [ "kvm-amd" ];
    kernelPackages = pkgs.linuxPackages_latest;

    # Avoid the NPU resume issue and chassis-specific wake and display quirks.
    blacklistedKernelModules = [ "amdxdna" ];
    kernelParams = [
      "acpi.ec_no_wakeup=1"
      "amdgpu.dcdebugmask=0x10"
    ];
  };

  # This laptop exposes s2idle instead of S3 suspend.
  systemd.sleep.settings.Sleep = {
    AllowSuspendThenHibernate = "yes";
    HibernateDelaySec = "1h";
    HibernateOnACPower = "no";
  };

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend-then-hibernate";
    HandleLidSwitchDocked = "ignore";
  };

  hardware'.bluetooth.enable = true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
