{
  config,
  lib,
  ...
}:
let
  cfg = config.services'.udisks2;
in
{
  options.services'.udisks2 = {
    enable = lib.mkEnableOption "UDisks2 daemon for storage devices";
  };

  config = lib.mkIf cfg.enable {
    services.udisks2.enable = true;
  };
}
