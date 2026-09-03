{
  config,
  lib,
  ...
}: let
  cfg = config.services'.gnome-keyring;
in {
  options.services'.gnome-keyring = {
    enable = lib.mkEnableOption "GNOME Keyring secret service";
  };

  config = {
    services.gnome.gnome-keyring.enable = lib.mkIf cfg.enable true;

    # Niri can also enable the native service, so follow its final state.
    preservation'.user.directories = lib.optionals config.services.gnome.gnome-keyring.enable [
      {
        directory = ".local/share/keyrings";
        mode = "0700";
      }
    ];
  };
}
