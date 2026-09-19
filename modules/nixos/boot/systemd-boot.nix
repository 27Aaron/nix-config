{
  config,
  lib,
  ...
}:
let
  cfg = config.boot'.systemd-boot;
  diskoCfg = config.storage'.disko;
in
{
  options.boot'.systemd-boot = {
    enable = lib.mkEnableOption "systemd-boot bootloader with EFI variable management";
  };

  config = lib.mkIf cfg.enable {
    # systemd-boot is UEFI-only, so a BIOS boot partition would be dead
    # weight; BIOS hosts should use boot'.grub instead. The mutual
    # exclusion with boot'.grub is asserted in grub.nix.
    assertions = [
      {
        assertion = !diskoCfg.bios.enable;
        message = "boot'.systemd-boot cannot be combined with storage'.disko.bios.enable; use boot'.grub for BIOS boot.";
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
