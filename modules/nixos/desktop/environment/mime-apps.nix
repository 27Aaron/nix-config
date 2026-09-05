{
  config,
  lib,
  pkgs,
  ...
}: let
  browser = [
    "firefox.desktop"
    "google-chrome.desktop"
  ];
  editor = [
    "dev.zed.Zed.desktop"
    "code.desktop"
    "org.gnome.TextEditor.desktop"
  ];
  archive = ["org.gnome.FileRoller.desktop"];
  fileManager = ["org.gnome.Nautilus.desktop"];
  imageViewer = ["org.gnome.Loupe.desktop"];
  mediaPlayer = ["mpv.desktop"];
  cfg = config.desktop'.mime-apps;
in {
  options.desktop'.mime-apps = {
    enable = lib.mkEnableOption "XDG MIME application associations";
  };

  config = lib.mkIf cfg.enable {
    hm'.home.packages = [pkgs.xdg-utils];

    # Replace an existing unmanaged file so old desktop preferences cannot
    # override the declarative defaults below.
    hm'.xdg.configFile."mimeapps.list".force = true;

    hm'.xdg.mimeApps = {
      enable = true;

      defaultApplications = {
        # Firefox is the default browser.
        "application/json" = browser;
        "application/pdf" = browser;
        "text/html" = browser;
        "text/xml" = browser;
        "application/xml" = browser;
        "application/xhtml+xml" = browser;
        "application/xhtml_xml" = browser;
        "application/rdf+xml" = browser;
        "application/rss+xml" = browser;
        "application/x-extension-htm" = browser;
        "application/x-extension-html" = browser;
        "application/x-extension-shtml" = browser;
        "application/x-extension-xht" = browser;
        "application/x-extension-xhtml" = browser;
        "x-scheme-handler/about" = browser;
        "x-scheme-handler/ftp" = browser;
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;

        # VS Code is preferred for text files; GNOME Text Editor is the
        # fallback.
        "text/plain" = editor;
        "application/x-zerosize" = editor;
        "application/x-wine-extension-ini" = editor;

        # VS Code uses a dedicated desktop entry for vscode:// URLs.
        "x-scheme-handler/vscode" = ["code-url-handler.desktop"];

        # Telegram URL links use the tg:// scheme.
        "x-scheme-handler/tg" = ["org.telegram.desktop.desktop"];

        # These applications are installed by applications.nix. Their
        # associations are listed explicitly so package metadata cannot
        # silently change the user's defaults.
        "audio/*" = mediaPlayer;
        "video/*" = mediaPlayer;
        "image/*" = imageViewer;
        "image/gif" = imageViewer;
        "image/jpeg" = imageViewer;
        "image/png" = imageViewer;
        "image/webp" = imageViewer;
        "inode/directory" = fileManager;

        # File Roller handles common archive formats.
        "application/bzip2" = archive;
        "application/gzip" = archive;
        "application/vnd.rar" = archive;
        "application/x-7z-compressed" = archive;
        "application/x-7z-compressed-tar" = archive;
        "application/x-bzip" = archive;
        "application/x-bzip-compressed-tar" = archive;
        "application/x-compressed-tar" = archive;
        "application/x-cpio" = archive;
        "application/x-gzip" = archive;
        "application/x-rar" = archive;
        "application/x-rar-compressed" = archive;
        "application/x-tar" = archive;
        "application/x-xz" = archive;
        "application/x-xz-compressed-tar" = archive;
        "application/x-zip" = archive;
        "application/x-zip-compressed" = archive;
        "application/zip" = archive;
        "application/zstd" = archive;
        "application/x-zstd-compressed-tar" = archive;
      };

      # Keep the association section explicit and leave unrelated desktop
      # entries untouched.
      associations.removed = {};
    };
  };
}
