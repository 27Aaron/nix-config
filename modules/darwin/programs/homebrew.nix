{
  config,
  lib,
  ...
}:
let
  cfg = config.programs'.homebrew;
in
{
  options.programs'.homebrew = {
    enable = lib.mkEnableOption "Homebrew package management";
  };

  config = lib.mkIf cfg.enable {
    homebrew = {
      enable = true;

      enableFishIntegration = config.programs.fish.enable;
      enableZshIntegration = config.programs.zsh.enable;

      onActivation = {
        upgrade = false;
        autoUpdate = false;
        cleanup = "zap";
      };

      taps = [ ];

      masApps = {
        "Bob" = 1630034110;
        "WPS" = 1443749478;
      };

      brews = [
        # Disk & Cleanup
        "mole"

        # Code Statistics
        "tokei"

        # Media
        "ffmpeg"
      ];

      casks = [
        # AI Development
        "cc-switch"
        "codexbar"
        "zcode"

        # Browser
        # "brave-browser"
        "firefox"
        "google-chrome"

        # Communication
        "feishu"
        "telegram"
        "wechat"

        # Development
        "orbstack"

        # Editor
        "visual-studio-code"
        "zed"

        # Font
        "font-lxgw-wenkai"
        "font-hack-nerd-font"
        "font-material-icons"
        "font-maple-mono-nf-cn"
        "font-jetbrains-mono-nerd-font"

        # Hardware
        "macs-fan-control"
        "monitorcontrol"

        # Input & Keyboard
        "input-source-pro"
        "karabiner-elements"

        # Knowledge Base
        "obsidian"

        # Media
        "iina"
        "neteasemusic"
        "obs"
        "plex"

        # Menu Bar
        "jordanbaird-ice@beta"

        # Network Tools
        "surge"

        # Productivity
        "qspace-pro"
        "raycast"

        # Remote Access
        "uuremote"

        # SSH Client
        "termius"

        # System Monitor
        "stats"

        # Terminal Emulator
        "ghostty"
        "kitty"
      ];
    };
  };
}
