{
  config,
  lib,
  ...
}:
let
  cfg = config.services'.gnome-keyring;
in
{
  options.services'.gnome-keyring = {
    enable = lib.mkEnableOption "GNOME Keyring secret service with Seahorse GUI";
  };

  config = {
    services.gnome.gnome-keyring.enable = lib.mkIf cfg.enable true;
    programs.seahorse.enable = lib.mkIf cfg.enable true;
    security.pam.services.passwd.enableGnomeKeyring = config.services.gnome.gnome-keyring.enable;

    preservation'.user.directories =
      lib.mkIf (config.services.gnome.gnome-keyring.enable && config.hardware'.persistence.enable)
        [
          {
            directory = ".local/share/keyrings";
            mode = "0700";
          }
        ];
  };
}
