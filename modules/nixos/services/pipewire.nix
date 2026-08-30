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

  config = lib.mkIf cfg.enable {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    # Let the audio server request real-time scheduling through RTKit.
    security.rtkit.enable = true;

    preservation'.user.directories = [
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
