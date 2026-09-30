{ ... }:
{
  imports = [
    ./btrfs-scrub.nix
    ./fail2ban.nix
    ./gnome-keyring.nix
    ./networkmanager.nix
    ./openssh.nix
    ./pipewire.nix
    ./power-profiles-daemon.nix
    ./smartd.nix
    ./upower.nix
    ./vnstat.nix
    ./zram.nix
  ];
}
