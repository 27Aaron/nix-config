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

    # Seahorse (keyring GUI) follows the same switch. Pitfall: never create a "Default keyring";
    # PAM only unlocks "login", so secrets would never sync with the login password.
    programs.seahorse.enable = lib.mkIf cfg.enable true;

    # Unlock the login keyring at greetd login and resync it on passwd, else Secret Service
    # clients (gh, browsers) keep prompting. greetd's PAM stack substacks `login` (carrying
    # pam_gnome_keyring), so no entry is needed here; gated on the service state.
    security.pam.services.passwd.enableGnomeKeyring = config.services.gnome.gnome-keyring.enable;

    # Niri can also enable the native service, so follow its final state.
    preservation'.user.directories = lib.optionals config.services.gnome.gnome-keyring.enable [
      {
        directory = ".local/share/keyrings";
        mode = "0700";
      }
    ];
  };
}
