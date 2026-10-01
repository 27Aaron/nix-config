{
  config,
  lib,
  ...
}:
let
  cfg = config.nixos.boot.systemd-boot;
in
{
  options.nixos.boot.systemd-boot.enable =
    lib.mkEnableOption "systemd-boot with EFI variable management";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !config.nixos.boot.grub.enable;
        message = "nixos.boot.systemd-boot and nixos.boot.grub are mutually exclusive";
      }
    ];

    boot.loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        editor = lib.mkDefault false;
        consoleMode = lib.mkDefault "max";
        configurationLimit = lib.mkDefault 8;
      };
    };
  };
}
