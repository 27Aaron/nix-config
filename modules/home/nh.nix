{ config, ... }:
{
  programs.nh = {
    enable = true;
    darwinFlake = "${config.home.homeDirectory}/nix-config";

    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep-since=7d";
    };
  };
}
