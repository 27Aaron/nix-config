{
  # Compose the shared system and Home Manager modules with the laptop session.
  imports = [
    ./default.nix
    ../../modules/nixos/desktop
  ];

  desktop' = {
    apps = {
      firefox.enable = true;
      google-chrome.enable = true;
      telegram.enable = true;
      vscode.enable = true;
      zed.enable = true;
    };
    fcitx5.enable = true;
    fonts.enable = true;
    greetd.enable = true;
    cursors.enable = true;
    mime-apps.enable = true;
    niri.enable = true;
    noctalia.enable = true;
    portal.enable = true;
    themes.enable = true;
    xdg-user-dirs.enable = true;
  };

  hardware'.amdgpu.enable = true;
}
