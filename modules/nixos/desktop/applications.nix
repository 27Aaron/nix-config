{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.desktop'.applications;
in {
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
      papers
      loupe

      # Media
      mpv
      ffmpegthumbnailer
    ];

    programs = {
      seahorse.enable = true;
    };

    # GVfs provides trash, network locations, MTP, and removable-media
    # integration for Nautilus.
    services.gvfs.enable = true;
    services.udisks2.enable = true;

    hm'.xdg.mimeApps = {
      enable = true;

      # Home Manager derives all supported MIME types from the applications'
      # desktop files. Earlier packages take precedence when MIME types overlap.
      defaultApplicationPackages = with pkgs; [
        file-roller
        nautilus
        loupe
        papers
        gnome-text-editor
        mpv
      ];
    };

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
