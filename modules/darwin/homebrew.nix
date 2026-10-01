{ ... }:
{
  homebrew = {
    enable = true;

    # Keep activation non-destructive.
    onActivation = {
      autoUpdate = false;
      cleanup = "none";
      upgrade = false;
    };

    # Command-line formulae.
    brews = [
      "ffmpeg"
      "mole"
      "tokei"
    ];

    # App Store applications.
    masApps = {
      "Bob" = 1630034110;
      "WPS" = 1443749478;
    };

    casks = [
      # AI tools.
      "cc-switch"
      "chatgpt"
      "claude-code"
      "codex"
      "codexbar"
      "grok-build"
      "zcode"

      # Browsers.
      "firefox"
      "google-chrome"

      # Desktop utilities.
      "input-source-pro"
      "jordanbaird-ice@beta"
      "karabiner-elements"
      "macs-fan-control"
      "monitorcontrol"
      "qspace-pro"
      "raycast"
      "stats"

      # Development.
      "orbstack"
      "visual-studio-code"
      "zed"

      # Fonts.
      "font-hack-nerd-font"
      "font-jetbrains-mono-nerd-font"
      "font-lxgw-wenkai"
      "font-maple-mono-nf-cn"
      "font-material-icons"

      # Media.
      "iina"
      "neteasemusic"
      "obs"
      "plex"

      # Networking.
      "feishu"
      "surge"
      "telegram"
      "termius"
      "uuremote"
      "wechat"

      # Notes.
      "obsidian"

      # Terminal.
      "ghostty"
    ];
  };
}
