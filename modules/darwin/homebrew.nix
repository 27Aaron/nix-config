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
      "tokei"
    ];

    casks = [
      "firefox"
      "font-jetbrains-mono-nerd-font"
      "font-maple-mono-nf-cn"
      "ghostty"
      "google-chrome"
      "karabiner-elements"
      "monitorcontrol"
      "obsidian"
      "orbstack"
      "raycast"
      "visual-studio-code"
      "zed"
    ];
  };
}
