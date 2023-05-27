{
  lib,
  config,
  ...
}: let
  cfg = config.services'.fail2ban;
in {
  options.services'.fail2ban = {
    enable = lib.mkEnableOption "Enable fail2ban service";
  };

  config = lib.mkIf cfg.enable {
    services.fail2ban.enable = true;

    preservation'.os.directories = [
      "/var/lib/fail2ban"
    ];
  };
}
