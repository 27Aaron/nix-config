{
  homebrew = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;

    onActivation = {
      autoUpdate = true; # Fetch the newest stable branch of Homebrew's git repo
      cleanup = "zap"; # Uninstall unlisted packages and their related files
      upgrade = true; # Upgrade outdated casks, formulae, and App Store apps
    };

    # Applications to install from Mac App Store using mas.
    masApps = {
      "Bob" = 1630034110;
      "WPS" = 1443749478;
    };

    # `brew install`
    brews = [
      # Disk & Cleanup
      "mole"
    ];

    # `brew install --cask`
    casks = [
      # AI Development
      "chatgpt"
      "cc-switch"
      "grok-build"
      "steipete/tap/codexbar"

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

      # Font
      "font-lxgw-wenkai"
      "font-hack-nerd-font"
      "font-material-icons"
      "font-maple-mono-nf-cn"
      "font-jetbrains-mono-nerd-font"

      # Hardware
      # "monitorcontrol"
      "macs-fan-control"

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
}
