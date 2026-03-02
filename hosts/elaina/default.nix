{
  imports = [
    ./hardware.nix
  ];

  desktop' = {
    cursors.enable = true;
    fonts.enable = true;
    greetd.enable = true;
    niri.enable = true;
    noctalia.enable = true;
  };

  programs' = {
    fcitx5.enable = true;
    firefox.enable = true;
    zed.enable = true;
  };

  services' = {
    networkmanager.enable = true;
    openssh.enable = true;
    vnstat.enable = true;
  };

  security'.firewall.enable = true;
}
