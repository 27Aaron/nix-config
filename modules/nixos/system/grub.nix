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
    boot.loader.grub = {
      enable = lib.mkDefault true;
      efiSupport = lib.mkDefault true;
      configurationLimit = lib.mkDefault 5;
      efiInstallAsRemovable = lib.mkDefault true;
    };

    # A BIOS boot partition (storage'.disko.bios.enable) means the machine
    # boots via legacy BIOS and GRUB must also be installed onto the disk
    # itself; the ESP stays populated as a fallback. Without it, GRUB
    # installs EFI-only.
    boot.loader.grub.device = lib.mkIf diskoCfg.bios.enable (
      lib.mkDefault diskoCfg.device
    );
  };
}
