{
  config,
  lib,
  username,
  ...
}:
let
  cfg = config.services'.pipewire;
in
{
  options.services'.pipewire = {
    enable = lib.mkEnableOption "PipeWire audio stack";
  };

  config = {
    services.pipewire = lib.mkIf cfg.enable {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    security.rtkit.enable = lib.mkIf cfg.enable true;

    preservation.preserveAt."/persistent".users.${username}.directories =
      lib.mkIf (cfg.enable && config.hardware'.persistence.enable)
        [
          {
            directory = ".config/pulse";
            mode = "0700";
          }
          {
            directory = ".local/state/wireplumber";
            mode = "0700";
          }
        ];
  };
}
