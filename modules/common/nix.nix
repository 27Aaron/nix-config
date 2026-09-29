# Cross-platform Nix configuration, shared by NixOS and nix-darwin hosts.
{ pkgs, ... }:
{
  nix = {
    enable = true;
    package = pkgs.nix;

    # Nix channels are not used; everything comes from flakes.
    channel.enable = false;

    optimise.automatic = true;

    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  nixpkgs.config.allowUnfree = true;
}
