{
  config,
  lib,
  ...
}: let
  cfg = config.desktop'.dms;
in {
  options.desktop'.dms = {
    enable = lib.mkEnableOption "DankMaterialShell desktop shell";
  };

  config = lib.mkIf cfg.enable {
    programs.dms-shell = {
      enable = true;
      systemd = {
        enable = true;
        target = "graphical-session.target";
      };
    };

    preservation'.user.directories = [
      # DankMaterialShell
      ".config/DankMaterialShell"
      {
        directory = ".local/state/DankMaterialShell";
        mode = "0700";
      }
    ];
  };
}
