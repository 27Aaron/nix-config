{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.desktop'.applications;
in {
  # Baseline set of file and media applications installed together on every
  # desktop host; apps that carry their own configuration live in separate
  # desktop'.apps.<app> modules instead.
  options.desktop'.applications = {
    enable = lib.mkEnableOption "desktop file and media applications";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # GNOME utilities
      gnome-calculator
      gnome-system-monitor
      gnome-text-editor

      # Files and documents
      nautilus
      file-roller
      loupe

      # Media
      mpv
      ffmpegthumbnailer
    ];

    # GVfs provides trash, network locations, MTP, and removable-media
    # integration for Nautilus.
    services.gvfs.enable = true;
    services.udisks2.enable = true;

    preservation'.user.directories = [
      # Desktop application launchers and file manager metadata
      {
        directory = ".local/share/applications";
        mode = "0700";
      }
      {
        directory = ".local/share/Trash";
        mode = "0700";
      }
      {
        directory = ".local/share/gvfs-metadata";
        mode = "0700";
      }

      # Certificate state used by desktop applications
      {
        directory = ".local/share/pki";
        mode = "0700";
      }
    ];
  };
}
