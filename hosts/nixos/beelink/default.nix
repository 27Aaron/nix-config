# beelink - Beelink SER6 Pro VEST (Ryzen 7 7735HS, 64 GB DDR5, 4 TB NVMe SSD)
{ ... }: {
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
    fail2ban.enable = true;
    networkmanager.enable = true;
    openssh.enable = true;
  };

  desktop' = {
    # Applications
    applications.enable = true;
    mime-apps.enable = true;
    apps.firefox.enable = true;
    apps.google-chrome.enable = true;
    apps.kitty.enable = true;
    apps.telegram.enable = true;
    apps.vscode.enable = true;
    apps.zed.enable = true;

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

  core'.firewall.enable = true;
  core'.kernel-hardening.enable = true;

  development'.ai.enable = true;
  development'.dev.enable = true;

  # Remote deployment via colmena.
  deployment.tags = [
    "homelab"
    "server"
  ];

  system.stateVersion = "26.05";
}
