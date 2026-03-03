{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.programs'.vscode;
in
{
  options.programs'.vscode = {
    enable = lib.mkEnableOption "Code editor developed by Microsoft";
  };

  config = lib.mkIf cfg.enable {
    hm'.home.packages = with pkgs; [ vscode-fhs ];

    preservation'.user.directories = [
      ".config/Code"
      ".vscode"
    ];
  };
}
