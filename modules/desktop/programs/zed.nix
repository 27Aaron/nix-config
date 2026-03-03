{
  lib,
  config,
  ...
}: let
  cfg = config.programs'.zed;
in {
  options.programs'.zed = {
    enable = lib.mkEnableOption "Zed code editor";
  };

  config = lib.mkIf cfg.enable {
    hm'.programs.zed-editor.enable = true;

    preservation'.user.directories = [
      ".cache/zed"
      ".config/zed"
      ".local/share/zed"
    ];
  };
}
