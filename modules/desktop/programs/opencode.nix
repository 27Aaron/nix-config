{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.programs'.opencode;
in
{
  options.programs'.opencode = {
    enable = lib.mkEnableOption "Opencode terminal-based AI coding assistant";
  };

  config = lib.mkIf cfg.enable {
    hm'.home.packages = with pkgs; [ opencode ];

    preservation'.user.directories = [
      ".cache/opencode"
      ".cache/.bun"
      ".local/share/opencode"
      ".local/state/opencode"
      ".config/opencode"
    ];
  };
}
