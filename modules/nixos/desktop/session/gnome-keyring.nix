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
    # Pitfall: never create a "Default keyring" in Seahorse — PAM only
    # unlocks the "login" keyring, so a second default keyring would fork
    # secrets into a container that never syncs with the login password.
    programs.seahorse.enable = lib.mkIf cfg.enable true;

    # Unlock the login keyring at greetd login, and keep it in sync when
    # the login password changes via passwd — without these, Secret
    # Service clients (gh, browsers) keep asking for a separate keyring
    # password.
    security.pam.services.greetd.enableGnomeKeyring = true;
    security.pam.services.passwd.enableGnomeKeyring = true;

    # Niri can also enable the native service, so follow its final state.
    preservation'.user.directories = lib.optionals config.services.gnome.gnome-keyring.enable [
      {
        directory = ".local/share/keyrings";
        mode = "0700";
      }
    ];
  };
}
