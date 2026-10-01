{
  config,
  lib,
  username,
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
    hm'.programs.vscode.enable = true;
    preservation.preserveAt."/persistent".users.${username}.directories =
      lib.mkIf (config.hardware'.persistence.enable)
        [
          ".config/Code"
          ".vscode"
        ];
  };
}
