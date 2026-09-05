{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.desktop'.apps.google-chrome;
in {
  options.desktop'.apps.google-chrome = {
    enable = lib.mkEnableOption "Google Chrome";
  };

  config = lib.mkIf cfg.enable {
    hm'.home.packages = [pkgs.google-chrome];

    preservation'.user.directories = [
      # Google Chrome profiles, extensions, and browser state.
      {
        directory = ".config/google-chrome";
        mode = "0700";
      }
    ];
  };
}
