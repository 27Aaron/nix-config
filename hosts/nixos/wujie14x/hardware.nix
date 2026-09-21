# Hardware profile for the MECHREVO WUJIE14XA (Wujie 14X Blizzard) laptop.
#
#   DMI        MECHREVO WUJIE14XA, board WUJIE14-GX4HRXL, BIOS N.1.14MRO50
#   CPU        AMD Ryzen 7 8845HS (Phoenix / Hawk Point), 8C/16T
#   Memory     2 x 16 GB DDR5-5600, Crucial/Micron CT16G56C46S5.C8D
#   GPU        Radeon 780M (HawkPoint1)                  [1002:1900]
#   Wi-Fi      MediaTek MT7922 (RZ616), mt7921e          [14c3:7922]
#   Bluetooth  13d3:3585, the Bluetooth half of the MT7922
#   Ethernet   Motorcomm YT6801, needs Linux >= 7.0      [1f0a:6801]
#   Touchpad   UNIW0001:00 093A:0255, on I2C rather than PS/2
#   Audio      Radeon HD Audio + Ryzen HD Audio  [1002:1640], [1022:15e3]
#   USB4       [1022:1669]; single-cable USB-C display output works
#   Storage    Micron 2550 NVMe SSD, 1 TB
#   TPM        present (/dev/tpm0)
#   Sensors    k10temp, amdgpu, nvme, BAT0, spd5118 x2
#   Power      s2idle only, the platform has no S3
#   Webcam     IR camera 04f2:b7dd; this model has no fingerprint sensor
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

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  boot = {
    initrd = {
      availableKernelModules = [
        "nvme"
        "sd_mod"
        "thunderbolt"
        "usb_storage"
        "xhci_pci"
      ];
    };

    kernelModules = [ "kvm-amd" ];

    # The XDNA NPU driver fails to power the NPU down on hibernate
    # (`amdxdna 0000:65:00.1: Power off failed, ret -110`), which aborts the
    # S4 transition and brings the system straight back up. Nothing here uses
    # the NPU, so keep the driver out of the way; drop this line to get the
    # NPU back.
    blacklistedKernelModules = [ "amdxdna" ];

    # The in-tree `dwmac-motorcomm` glue driver handles the YT6801 Ethernet
    # controller from Linux 7.0 onwards, so the out-of-tree `yt6801` module is
    # not needed here. On an older kernel this would have to become
    # `boot.extraModulePackages = [ config.boot.kernelPackages.yt6801 ]`.
    kernelPackages = pkgs.linuxPackages_latest;

    # Two quirks that are specific to this chassis. Both are documented for
    # exactly this model and are needed for the laptop to be usable at all:
    #
    #   acpi.ec_no_wakeup=1
    #     The embedded controller sends spurious wakeups, so without this the
    #     machine resumes from s2idle the instant the lid is closed.
    #
    #   amdgpu.dcdebugmask=0x10
    #     Disables Panel Self Refresh. On this 2880x1800 eDP panel with
    #     Phoenix/Hawk Point graphics, PSR causes flicker and glitching
    #     (freedesktop.org/drm/amd#3388).
    #
    # If the keyboard or touchpad stop responding after a resume, add
    # "i8042.nomux" (and, if that is not enough, "i8042.nopnp" and
    # "i8042.noloop"); other units of this board need the full trio.
    kernelParams = [
      "acpi.ec_no_wakeup=1"
      "amdgpu.dcdebugmask=0x10"
    ];
  };

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  hardware' = {
    amdgpu.enable = true;
    bluetooth.enable = true;
    systemd-boot.enable = true;

    # The layout the previous installation used on this disk: a 1 GiB ESP plus
    # a LUKS container holding the Btrfs pool. The device is referenced by its
    # stable by-id path rather than /dev/nvme0n1.
    disko = {
      enable = true;
      device = "/dev/disk/by-id/nvme-CT1000P3PSSD8_24364AD5D8E0";
      espSize = "1G";
      swapSize = "32G";
      luks.enable = true;
    };

    persistence.enable = true;
  };
}
