{
  config,
  lib,
  ...
}:
let
  cfg = config.hardware'.systemd-boot;
  diskoCfg = config.hardware'.disko;
in
{
  options.hardware'.systemd-boot = {
    enable = lib.mkEnableOption "systemd-boot bootloader with EFI variable management";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !diskoCfg.bios.enable;
        message = "hardware'.systemd-boot cannot be combined with hardware'.disko.bios.enable; use hardware'.grub for BIOS boot.";
      }
    ];

    boot.loader = {
      systemd-boot = {
        enable = true;
        editor = lib.mkDefault false;
        consoleMode = lib.mkDefault "max";
        configurationLimit = lib.mkDefault 8;
      };

      efi.canTouchEfiVariables = true;
    };
  };
}
