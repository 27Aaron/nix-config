{
  config,
  lib,
  ...
}: let
  cfg = config.services'.printing;
in {
  options.services'.printing = {
    enable = lib.mkEnableOption "CUPS printing service";
  };

  config = lib.mkIf cfg.enable {
    services.printing.enable = true;

    preservation'.os.directories = [
      {
        directory = "/var/cache/cups";
        group = "lp";
        mode = "0770";
      }
      {
        directory = "/var/lib/cups";
        user = "cups";
        group = "lp";
      }
      {
        directory = "/var/spool/cups";
        group = "lp";
        mode = "0710";
      }
    ];
  };
}
