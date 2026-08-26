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
    services.printing.enable = lib.mkDefault true;
  };
}
