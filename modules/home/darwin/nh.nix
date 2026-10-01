{ config, ... }:
{
  programs.nh = {
    enable = true;
    darwinFlake = "${config.home.homeDirectory}/nix-config";

    # Clean weekly while retaining the last seven days.
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep-since=7d";
    };
  };
}
