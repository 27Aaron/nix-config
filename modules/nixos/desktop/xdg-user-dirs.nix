{
  config,
  lib,
  ...
}: let
  cfg = config.desktop'.xdg-user-dirs;
in {
  options.desktop'.xdg-user-dirs.enable = lib.mkEnableOption "XDG user directories";

  config = lib.mkIf cfg.enable {
    hm'.xdg = {
      enable = true;

      userDirs = {
        enable = true;
        createDirectories = false;
        desktop = "$HOME/Desktop";
        documents = "$HOME/Documents";
        download = "$HOME/Downloads";
        music = "$HOME/Music";
        pictures = "$HOME/Pictures";
        publicShare = "/var/empty";
        templates = "/var/empty";
        videos = "$HOME/Videos";
      };
      configFile."user-dirs.locale".text = "en_US";
    };

    preservation'.user.directories = [
      {
        directory = "Desktop";
        mountOptions = ["x-gvfs-trash"];
      }
      {
        directory = "Documents";
        mountOptions = ["x-gvfs-trash"];
      }
      {
        directory = "Downloads";
        mountOptions = ["x-gvfs-trash"];
      }
      {
        directory = "Music";
        mountOptions = ["x-gvfs-trash"];
      }
      {
        directory = "Pictures";
        mountOptions = ["x-gvfs-trash"];
      }
      {
        directory = "Videos";
        mountOptions = ["x-gvfs-trash"];
      }
    ];
  };
}
