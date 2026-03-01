{
  imports = [
    ./hardware.nix
  ];

  desktop' = {
    greetd.enable = true;
    niri.enable = true;
  };

  programs' = {
    firefox.enable = true;
    steam.enable = true;
    zed.enable = true;
  };

  services' = {
    networkmanager.enable = true;
    openssh.enable = true;
    vnstat.enable = true;
  };

  security'.firewall.enable = true;
}
