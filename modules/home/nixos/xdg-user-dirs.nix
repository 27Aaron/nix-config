{
  lib,
  osConfig,
  ...
}:
let
  enable = osConfig.desktop'.xdg-user-dirs.enable;
in
{
  xdg = lib.mkIf enable {
    enable = true;

    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "$HOME/Desktop";
      documents = "$HOME/Documents";
      download = "$HOME/Downloads";
      music = "$HOME/Music";
      pictures = "$HOME/Pictures";
      publicShare = null;
      templates = null;
      videos = "$HOME/Videos";
    };
    configFile."user-dirs.locale".text = "en_US";
  };
}
