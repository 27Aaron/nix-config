{
  config,
  lib,
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

    # Let the audio server request real-time scheduling through RTKit.
    security.rtkit.enable = lib.mkIf cfg.enable true;

    # Upstream consumers may enable this stack on their own, so persistence
    # follows the final service state, whoever turned it on.
    preservation'.user.directories = lib.optionals config.services.pipewire.enable [
      # PulseAudio compatibility cookie
      {
        directory = ".config/pulse";
        mode = "0700";
      }
      # WirePlumber saved routes and devices
      {
        directory = ".local/state/wireplumber";
        mode = "0700";
      }
    ];
  };
}
