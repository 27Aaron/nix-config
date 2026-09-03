{
  lib,
  config,
  ...
}: let
  cfg = config.boot'.grub;
  diskoCfg = config.storage'.disko;
in {
  options.boot'.grub = {
    enable = lib.mkEnableOption "GRUB bootloader";
  };

  config = lib.mkIf cfg.enable {
    # The two bootloaders are mutually exclusive; upstream does not enforce
    # this, so the repo-level switches have to.
    assertions = [
      {
        assertion = !config.boot'.systemd-boot.enable;
        message = "boot'.grub and boot'.systemd-boot are mutually exclusive; enable only one.";
      }
    ];

    boot.loader.grub = {
      enable = true;
      efiSupport = lib.mkDefault true;
      # Removable install boots via the fallback \EFI\BOOT path, so firmware
      # never needs an NVRAM entry — and upstream forbids pairing this with
      # boot.loader.efi.canTouchEfiVariables anyway.
      efiInstallAsRemovable = lib.mkDefault true;
      configurationLimit = lib.mkDefault 8;

      # With a BIOS boot partition (storage'.disko.bios.enable) GRUB also
      # installs onto the disk itself, with the ESP staying populated as a
      # fallback; pure UEFI hosts install nothing but the removable EFI
      # binary, which upstream expresses as the special device "nodev".
      device = lib.mkDefault (
        if diskoCfg.bios.enable
        then diskoCfg.device
        else "nodev"
      );

      # Kernels live in the Nix store on the encrypted btrfs root, so GRUB
      # must open the LUKS container itself before loading them.
      enableCryptodisk = lib.mkIf diskoCfg.luks.enable (lib.mkDefault true);
    };
  };
}
