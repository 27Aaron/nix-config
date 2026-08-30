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

  config = lib.mkIf cfg.enable {
    services.accounts-daemon.enable = true;

    preservation'.os.directories = [
      {
        directory = "/var/lib/AccountsService";
        mode = "0775";
      }
    ];
  };
}
