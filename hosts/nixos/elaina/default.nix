#####################################################
#
# Elaina - MECHREVO Wujie 14X laptop
#   (Ryzen 7 8845HS, 32 GB DDR5, 2 TB SSD)
#
#####################################################
{ ... }:
{
  imports = [
    ./hardware.nix
  ];

  services' = {
    avahi.enable = true;
    btrbk.enable = true;
    btrfs-scrub.enable = true;
    fail2ban.enable = true;
    gnome-keyring.enable = true;
    networkmanager.enable = true;
    openssh.enable = true;
    pipewire.enable = true;
    power-profiles-daemon.enable = true;
    smartd.enable = true;
    upower.enable = true;
    vnstat.enable = true;
    zram.enable = true;
  };

  desktop' = {
    applications.enable = true;
    mime-apps.enable = true;
    apps = {
      firefox.enable = true;
      kitty.enable = true;
      vscode.enable = true;
    };
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

  tools'.ai.enable = true;
  tools'.dev.enable = true;

  # Remote deployment via colmena.
  deployment.tags = [ "laptop" ];

  system.stateVersion = "26.05";
}
