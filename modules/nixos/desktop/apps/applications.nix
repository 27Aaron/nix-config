{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.desktop'.applications;
in
{
  options.desktop'.applications = {
    enable = lib.mkEnableOption "desktop file and media applications";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gnome-calculator
      gnome-system-monitor
      gnome-text-editor
      nautilus
      file-roller
      loupe
      mpv
      ffmpegthumbnailer
    ];

    services'.gvfs.enable = true;
    services.udisks2.enable = true;

    preservation'.user.directories = lib.mkIf config.hardware'.persistence.enable [
      {
        directory = ".local/share/applications";
        mode = "0700";
      }
      {
        directory = ".local/share/Trash";
        mode = "0700";
      }
      {
        directory = ".local/share/pki";
        mode = "0700";
      }
    ];
  };
}
