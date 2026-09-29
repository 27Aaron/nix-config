{
  config,
  lib,
  ...
}:
let
  cfg = config.services'.fail2ban;
in
{
  options.services'.fail2ban = {
    enable = lib.mkEnableOption "fail2ban service";
  };

  config = lib.mkIf cfg.enable {
    services.fail2ban = {
      enable = true;
      bantime = "1h";
      bantime-increment = {
        enable = true;
        maxtime = "1w";
        rndtime = "10m";
      };
    };

    preservation'.os.directories = [ "/var/lib/fail2ban" ];
  };
}
