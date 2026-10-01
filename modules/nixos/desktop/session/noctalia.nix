{
  config,
  lib,
  username,
  ...
}:
let
  cfg = config.desktop'.noctalia;
in
{
  options.desktop'.noctalia = {
    enable = lib.mkEnableOption "Noctalia desktop shell";
  };

  config = lib.mkIf cfg.enable {
    programs.noctalia = {
      enable = true;
      systemd.enable = true;
    };

    preservation.preserveAt."/persistent".users.${username}.directories =
      lib.mkIf (config.hardware'.persistence.enable)
        [
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
