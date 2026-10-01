{
  fullName,
  hostName,
  lib,
  pkgs,
  timeZone,
  ...
}:
{
  networking.hostName = hostName;
  time.timeZone = lib.mkDefault timeZone;

  # Keep terminal support and system documentation predictable across hosts.
  environment.enableAllTerminfo = lib.mkDefault true;
  documentation = {
    man.cache.enable = false;
    nixos.enable = false;
  };

  programs.fish.enable = true;
  user' = {
    isNormalUser = true;
    description = fullName;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
  };
}
