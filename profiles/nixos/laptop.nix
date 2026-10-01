{
  # Compose the shared system and Home Manager modules with the laptop session.
  imports = [
    ./default.nix
    ../../modules/nixos/desktop
  ];

  desktop' = {
    apps = {
      firefox.enable = true;
      vscode.enable = true;
      zed.enable = true;
    };
    fcitx5.enable = true;
    fonts.enable = true;
    greetd.enable = true;
    niri.enable = true;
    portal.enable = true;
  };
}
