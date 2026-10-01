{ lib, ... }:
{
  imports = [
    ./core/kernel-hardening.nix
    ./host.nix
    ./hardware/bluetooth.nix
    ./hardware/boot/grub.nix
    ./hardware/boot/initrd-ssh.nix
    ./hardware/boot/systemd-boot.nix
    ./services/btrfs-scrub.nix
    ./services/gnome-keyring.nix
    ./services/networkmanager.nix
    ./services/openssh.nix
    ./services/pipewire.nix
    ./services/power-profiles-daemon.nix
    ./services/smartd.nix
    ./services/upower.nix
    ./services/zram.nix
  ];

  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.channel.enable = false;
  nixpkgs.config.allowUnfree = true;

}
