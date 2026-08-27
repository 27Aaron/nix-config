{
  config,
  lib,
  ...
}: let
  cfg = config.hardware'.bluetooth;
in {
  options.hardware'.bluetooth.enable = lib.mkEnableOption "Bluetooth support";

  config = {
    hardware.bluetooth.enable = lib.mkIf cfg.enable true;

    # Persistence follows the final service state, whoever turned it on.
    preservation'.os.directories = lib.optionals config.hardware.bluetooth.enable [
      # Bluetooth
      {
        directory = "/var/lib/bluetooth";
        mode = "0700";
      }
    ];
  };
}
