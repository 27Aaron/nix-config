#####################################################
#
# Beelink SER6 Pro VEST - homelab server
#   (Ryzen 7 7735HS, 64 GB DDR5, 4 TB NVMe SSD)
#
#####################################################
{...}: {
  imports = [
    ./hardware.nix
  ];

  services' = {
    avahi.enable = true;

    # Desktop support
    gnome-keyring.enable = true;
    pipewire.enable = true;
    power-profiles-daemon.enable = true;
    upower.enable = true;

    # Storage and monitoring
    btrbk.enable = true;
    btrfs-scrub.enable = true;
    smartd.enable = true;
    vnstat.enable = true;
    zram.enable = true;

    # Network access
    networkmanager.enable = true;
    openssh.enable = true;
    openssh.port = 233;
  };

  desktop' = {
    # Applications
    applications.enable = true;
    apps.kitty.enable = true;
    apps.vscode.enable = true;

    # Session and appearance
    cursors.enable = true;
    fcitx5.enable = true;
    fonts.enable = true;
    greetd.enable = true;
    niri.autoLogin = true;
    niri.enable = true;
    noctalia.enable = true;
    themes.enable = true;
    xdg-user-dirs.enable = true;
  };

  security'.firewall.enable = true;
  security'.kernel-hardening.enable = true;

  tools'.dev.enable = true;

  system.stateVersion = "26.05";
}
