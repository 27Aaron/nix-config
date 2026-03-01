{
  lib,
  config,
  ...
}:
let
  cfg = config.programs'.firefox;
in
{
  options.programs'.firefox = {
    enable = lib.mkEnableOption "Firefox web browser";
  };

  config = lib.mkIf cfg.enable {
    hm'.programs.firefox.enable = true;

    preservation'.user.directories = [
      ".cache/mozilla"
      ".config/mozilla"
    ];
  };
}
