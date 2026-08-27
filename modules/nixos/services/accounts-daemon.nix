{
  config,
  lib,
  ...
}: let
  cfg = config.services'.accounts-daemon;
in {
  options.services'.accounts-daemon = {
    enable = lib.mkEnableOption "AccountsService daemon";
  };

  config = {
    services.accounts-daemon.enable = lib.mkIf cfg.enable true;

    # Persistence follows the final service state, whoever turned it on.
    preservation'.os.directories = lib.optionals config.services.accounts-daemon.enable [
      {
        directory = "/var/lib/AccountsService";
        mode = "0775";
      }
    ];
  };
}
