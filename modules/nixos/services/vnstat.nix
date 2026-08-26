{
  config,
  lib,
  ...
}: let
  cfg = config.services'.vnstat;
in {
  options.services'.vnstat = {
    enable = lib.mkEnableOption "Vnstat network traffic monitor";
  };

  config = lib.mkIf cfg.enable {
    services.vnstat.enable = lib.mkDefault true;
  };
}
