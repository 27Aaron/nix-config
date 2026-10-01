{
  config,
  lib,
  ...
}:
let
  cfg = config.nixos.boot.grub;
  diskoCfg = config.nixos.disko;
in
{
  options.nixos.boot.grub.enable = lib.mkEnableOption "the GRUB bootloader";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !config.nixos.boot.systemd-boot.enable;
        message = "nixos.boot.grub and nixos.boot.systemd-boot are mutually exclusive";
      }
    ];

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
