{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.programs'.claudecode;
in
{
  options.programs'.claudecode = {
    enable = lib.mkEnableOption "Claude Code CLI tool";
  };

  config = lib.mkIf cfg.enable {
    hm'.home.packages = with pkgs; [ claude-code ];

    preservation'.user.directories = [
      ".claude"
    ];

    preservation'.user.files = [
      ".claude.json"
    ];
  };
}
