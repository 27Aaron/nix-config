{ ... }:
{
  imports = [
    ./core/fish.nix
    ./core/i18n.nix
    ./core/nix.nix
    ./core/host.nix
    ./hardware/amdgpu.nix
    ./hardware/bluetooth.nix
    ./hardware/disable-balloon.nix
    ./hardware/boot/grub.nix
    ./hardware/boot/initrd-ssh.nix
    ./hardware/boot/systemd-boot.nix
    ./services/btrfs-scrub.nix
    ./services/btrbk.nix
    ./services/avahi.nix
    ./services/fail2ban.nix
    ./services/gnome-keyring.nix
    ./services/gvfs.nix
    ./services/networkmanager.nix
    ./services/openssh.nix
    ./services/pipewire.nix
    ./services/power-profiles-daemon.nix
    ./services/smartd.nix
    ./services/upower.nix
    ./services/vnstat.nix
    ./services/zram.nix
    ./security/firewall.nix
  ];

}
