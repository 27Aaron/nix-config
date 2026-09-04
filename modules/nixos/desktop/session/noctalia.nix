{
  config,
  lib,
  ...
}: let
  cfg = config.desktop'.noctalia;
in {
  options.desktop'.noctalia = {
    enable = lib.mkEnableOption "Noctalia desktop shell";
  };

  config = lib.mkIf cfg.enable {
    programs.noctalia = {
      enable = true;
      systemd.enable = true;
    };

    # Keep Noctalia's GUI-managed configuration and runtime data across
    # reboots while leaving all settings editable from its UI.
    preservation'.user.directories = [
      {
        directory = ".config/noctalia";
        mode = "0700";
      }
      {
        directory = ".local/state/noctalia";
        mode = "0700";
      }
      {
        directory = ".local/share/noctalia";
        mode = "0700";
      }
    ];
  };
}
