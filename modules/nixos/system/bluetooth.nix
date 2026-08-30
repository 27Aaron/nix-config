{
  config,
  lib,
  ...
}: let
  cfg = config.hardware'.bluetooth;
in {
  options.hardware'.bluetooth = {
    enable = lib.mkEnableOption "Bluetooth support";
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth.enable = true;

    preservation'.os.directories = [
      # Bluetooth
      {
        directory = "/var/lib/bluetooth";
        mode = "0700";
      }
    ];
  };
}
