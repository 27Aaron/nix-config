{
  config,
  lib,
  ...
}: let
  cfg = config.services'.gnome-keyring;
in {
  options.services'.gnome-keyring = {
    enable = lib.mkEnableOption "GNOME Keyring secret service with Seahorse GUI";
  };

  config = {
    services.gnome.gnome-keyring.enable = lib.mkIf cfg.enable true;

    # Seahorse is the keyring's GUI front-end and is useless on its own,
    # so it follows the same switch.
    programs.seahorse.enable = lib.mkIf cfg.enable true;

    # Niri can also enable the native service, so follow its final state.
    preservation'.user.directories = lib.optionals config.services.gnome.gnome-keyring.enable [
      {
        directory = ".local/share/keyrings";
        mode = "0700";
      }
    ];
  };
}
