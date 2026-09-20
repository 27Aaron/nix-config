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
    # systemd-boot is UEFI-only, so a BIOS boot partition would be dead
    # weight; BIOS hosts should use hardware'.grub instead. The mutual
    # exclusion with hardware'.grub is asserted in grub.nix.
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

      # bootctl registers the "Linux Boot Manager" NVRAM entry on install;
      # this shared EFI-layer option is what allows it to do so.
      efi.canTouchEfiVariables = true;
    };
  };
}
