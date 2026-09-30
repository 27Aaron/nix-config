# MECHREVO Wujie 14XA - Ryzen 7 8845HS laptop (32 GB RAM, 1 TB NVMe)
{ ... }:
{
  modules = [
    ./hardware.nix

    {
      development'.ai.enable = true;
      development'.dev.enable = true;

      desktop'.applications.enable = true;
      desktop'.apps.firefox.enable = true;
      desktop'.apps.kitty.enable = true;
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

      services'.btrfs-scrub.enable = true;
      services'.gnome-keyring.enable = true;
      services'.networkmanager.enable = true;
      services'.openssh.enable = true;
      services'.pipewire.enable = true;
      services'.power-profiles-daemon.enable = true;
      services'.smartd.enable = true;
      services'.upower.enable = true;
      services'.zram.enable = true;

      security'.firewall.enable = true;
    }
  ];

  system = "x86_64-linux";
  stateVersion = "26.05";
}
