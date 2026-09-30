{
  config,
  lib,
  ...
}:
let
  cfg = config.desktop'.apps.vscode;
in
{
  options.desktop'.apps.vscode = {
    enable = lib.mkEnableOption "Visual Studio Code";
  };

  config = lib.mkIf cfg.enable {
    preservation'.user.directories = [
      ".config/Code"
      ".vscode"
    ];
  };
}
