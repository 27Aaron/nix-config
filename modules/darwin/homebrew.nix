{ ... }:
{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      cleanup = "none";
      upgrade = false;
    };

    brews = [
      "ffmpeg"
      "mole"
      "tokei"
    ];

    masApps = {
      "Bob" = 1630034110;
      "WPS" = 1443749478;
    };

    casks = [
      "cc-switch"
      "chatgpt"
      "codexbar"
      "firefox"
      "font-jetbrains-mono-nerd-font"
      "font-hack-nerd-font"
      "font-lxgw-wenkai"
      "font-maple-mono-nf-cn"
      "font-material-icons"
      "ghostty"
      "google-chrome"
      "grok-build"
      "iina"
      "input-source-pro"
      "jordanbaird-ice@beta"
      "karabiner-elements"
      "macs-fan-control"
      "monitorcontrol"
      "neteasemusic"
      "obs"
      "obsidian"
      "orbstack"
      "plex"
      "qspace-pro"
      "raycast"
      "stats"
      "surge"
      "telegram"
      "termius"
      "uuremote"
      "visual-studio-code"
      "wechat"
      "zcode"
      "zed"
    ];
  };
}
