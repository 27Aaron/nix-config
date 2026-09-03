{
  config,
  lib,
  ...
}: let
  cfg = config.services'.fail2ban;
in {
  options.services'.fail2ban = {
    enable = lib.mkEnableOption "fail2ban service";

    ignoreIP = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = ''
        IP addresses, CIDR masks or DNS hosts that fail2ban will never ban,
        for trusted networks such as a VPN or office range.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.fail2ban = {
      enable = true;
      ignoreIP = cfg.ignoreIP;
      bantime = "1h";
      bantime-increment = {
        enable = true;
        maxtime = "1w";
        rndtime = "10m";
      };
    };

    preservation'.os.directories = ["/var/lib/fail2ban"];
  };
}
