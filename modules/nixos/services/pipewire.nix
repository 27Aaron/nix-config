{
  config,
  lib,
  ...
}: let
  cfg = config.services'.pipewire;
in {
  options.services'.pipewire = {
    enable = lib.mkEnableOption "PipeWire audio stack";
  };

  config = {
    services.pipewire = {
      alsa.enable = lib.mkIf cfg.enable true;
      enable = lib.mkIf cfg.enable true;
      pulse.enable = lib.mkIf cfg.enable true;
      wireplumber.enable = lib.mkIf cfg.enable true;
    };

    # Let the audio server request real-time scheduling through RTKit.
    security.rtkit.enable = lib.mkIf cfg.enable true;

    # Persistence follows the final service state, whoever turned it on.
    preservation'.user.directories =
      lib.optionals (config.services.pulseaudio.enable || config.services.pipewire.pulse.enable) [
        # PulseAudio compatibility cookie
        {
          directory = ".config/pulse";
          mode = "0700";
        }
      ]
      ++ lib.optionals config.services.pipewire.wireplumber.enable [
        # WirePlumber
        {
          directory = ".local/state/wireplumber";
          mode = "0700";
        }
      ];
  };
}
