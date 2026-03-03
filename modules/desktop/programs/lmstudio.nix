{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.programs'.lmstudio;
in {
  options.programs'.lmstudio = {
    enable = lib.mkEnableOption "LM Studio - Run local LLMs";
  };

  config = lib.mkIf cfg.enable {
    hm'.home.packages = with pkgs; [lmstudio];

    preservation'.user.directories = [
      ".lmstudio"
      ".config/LM Studio"
    ];
  };
}
