{ ... }:
{
  homebrew = {
    enable = true;

    # Keep upgrades and package removal manual.
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
      # Development and AI tools.
      "cc-switch"
      "chatgpt"
      "codexbar"
      "grok-build"
      "orbstack"
      "visual-studio-code"
      "zcode"
      "zed"

      # Browsers and terminals.
      "firefox"
      "ghostty"
      "google-chrome"

      # Fonts.
      "font-hack-nerd-font"
      "font-jetbrains-mono-nerd-font"
      "font-lxgw-wenkai"
      "font-maple-mono-nf-cn"
      "font-material-icons"

      # Media and notes.
      "iina"
      "neteasemusic"
      "obs"
      "obsidian"
      "plex"

      # Networking, messaging, and remote access.
      "surge"
      "telegram"
      "termius"
      "uuremote"
      "wechat"

      # Desktop and hardware utilities.
      "input-source-pro"
      "jordanbaird-ice@beta"
      "karabiner-elements"
      "macs-fan-control"
      "monitorcontrol"
      "qspace-pro"
      "raycast"
      "stats"
    ];
  };
}
