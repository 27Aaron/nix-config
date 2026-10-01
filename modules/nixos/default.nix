{
  hostName,
  timeZone,
  fullName,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware/boot/grub.nix
    ./hardware/boot/initrd-ssh.nix
    ./hardware/boot/systemd-boot.nix
    ./services/btrfs-scrub.nix
    ./services/openssh.nix
    ./services/pipewire.nix
    ./services/power-profiles-daemon.nix
    ./services/upower.nix
    ./services/zram.nix
  ];

  networking.hostName = hostName;
  networking.firewall.enable = lib.mkDefault true;
  time.timeZone = lib.mkDefault timeZone;
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.channel.enable = false;
  nixpkgs.config.allowUnfree = true;

  programs.fish.enable = true;
  user' = {
    isNormalUser = true;
    description = fullName;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
  };
}
