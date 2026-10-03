{ config, ... }:
{
  programs.nh = {
    enable = true;
    darwinFlake = "${config.home.homeDirectory}/nix-config";
  };
}
