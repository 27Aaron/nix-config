{
  config,
  lib,
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
    preservation'.user.directories = [
      # Zed settings, keymaps, extensions, and language-server state.
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
