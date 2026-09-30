# Beelink SER6 Pro VEST - Ryzen 7 7735HS mini PC (64 GB DDR5, 4 TB NVMe SSD)
{ ... }:
{
  modules = [
    ./hardware.nix

    {
      development'.ai.enable = true;
      development'.dev.enable = true;

      desktop'.applications.enable = true;
      desktop'.apps.firefox.enable = true;
      desktop'.apps.google-chrome.enable = true;
      desktop'.apps.kitty.enable = true;
      desktop'.apps.telegram.enable = true;
      desktop'.apps.vscode.enable = true;
      desktop'.apps.zed.enable = true;
      desktop'.cursors.enable = true;
      desktop'.fcitx5.enable = true;
      desktop'.fonts.enable = true;
      desktop'.greetd.enable = true;
      desktop'.mime-apps.enable = true;
      desktop'.niri.enable = true;
      desktop'.niri.autoLogin = true;
      desktop'.noctalia.enable = true;
      desktop'.themes.enable = true;
      desktop'.xdg-user-dirs.enable = true;

      services'.avahi.enable = true;
      services'.btrbk.enable = true;
      services'.btrfs-scrub.enable = true;
      services'.fail2ban.enable = true;
      services'.gnome-keyring.enable = true;
      services'.networkmanager.enable = true;
      services'.openssh.enable = true;
      services'.pipewire.enable = true;
      services'.power-profiles-daemon.enable = true;
      services'.smartd.enable = true;
      services'.upower.enable = true;
      services'.vnstat.enable = true;
      services'.zram.enable = true;

      security'.firewall.enable = true;
    }
  ];

  system = "x86_64-linux";
  stateVersion = "26.05";
}
