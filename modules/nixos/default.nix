{
  hostName,
  timeZone,
  username,
  fullName,
  lib,
  pkgs,
  ...
}:
{
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
  users.users.${username} = {
    isNormalUser = true;
    description = fullName;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
  };
}
