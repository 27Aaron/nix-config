{
  config,
  lib,
  username,
  ...
}:
let
  cfg = config.desktop'.apps.zed;
in
{
  options.desktop'.apps.zed = {
    enable = lib.mkEnableOption "Zed editor";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${username}.programs.zed-editor.enable = true;
    preservation.preserveAt."/persistent".users.${username}.directories =
      lib.mkIf (config.hardware'.persistence.enable)
        [
          {
            directory = ".config/zed";
            mode = "0700";
          }
          {
            directory = ".local/share/zed";
            mode = "0700";
          }
        ];
  };
}
