{
  lib,
  config,
  ...
}:
let
  cfg = config.hardware'.grub;
  diskoCfg = config.hardware'.disko;
in
{
  options.hardware'.grub = {
    enable = lib.mkEnableOption "GRUB bootloader";
  };

  config = lib.mkIf cfg.enable {
    # The two bootloaders are mutually exclusive; upstream does not enforce
    # this, so the repo-level switches have to.
    assertions = [
      {
        assertion = !config.hardware'.systemd-boot.enable;
        message = "hardware'.grub and hardware'.systemd-boot are mutually exclusive; enable only one.";
      }
    ];

    boot.loader.grub = {
      enable = true;
      efiSupport = lib.mkDefault true;
      # Removable install boots via \EFI\BOOT, needing no NVRAM entry; upstream
      # also forbids pairing this with boot.loader.efi.canTouchEfiVariables.
      efiInstallAsRemovable = lib.mkDefault true;
      configurationLimit = lib.mkDefault 8;

      # With a BIOS boot partition GRUB also installs onto the disk itself (ESP
      # kept as fallback); pure UEFI hosts use upstream's special "nodev" device.
      device = lib.mkDefault (if diskoCfg.bios.enable then diskoCfg.device else "nodev");

      # Kernels live in the Nix store on the encrypted btrfs root, so GRUB
      # must open the LUKS container itself before loading them.
      enableCryptodisk = lib.mkIf diskoCfg.luks.enable (lib.mkDefault true);
    };
  };
}
