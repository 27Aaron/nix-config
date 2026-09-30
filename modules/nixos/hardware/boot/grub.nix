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
    boot.loader.grub = {
      enable = true;
      efiSupport = lib.mkDefault true;
      efiInstallAsRemovable = lib.mkDefault true;
      configurationLimit = lib.mkDefault 8;
      device = lib.mkDefault (if diskoCfg.bios.enable then diskoCfg.device else "nodev");
      enableCryptodisk = lib.mkIf diskoCfg.luks.enable (lib.mkDefault true);
    };
  };
}
